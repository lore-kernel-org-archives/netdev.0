From: "Isaula Oscar-QOI000" <Oscar.Isaula@motorola.com>
Subject: RE: [SCTP] Initialization collision problem
Date: Thu, 3 May 2007 09:52:35 -0500
Message-ID: <5F14EEE91CB6694A86535A0A028D9C55016AF3E1@tx14exm60.ds.mot.com>
References: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com> <461CF473.7010307@hp.com> <5F14EEE91CB6694A86535A0A028D9C55016AEDF2@tx14exm60.ds.mot.com> <4637A0B1.20900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail119.messagelabs.com ([216.82.241.179]:48325 "HELO
	mail119.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1162069AbXECOwf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 10:52:35 -0400
Received: from az33exr01.mot.com (az33exr01.mot.com [10.64.251.231])
	by motgate5.mot.com (8.12.11/Motorola) with ESMTP id l43EqWg3027035
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 07:52:32 -0700 (MST)
Received: from az10vts04 (az10vts04.mot.com [10.64.251.245])
	by az33exr01.mot.com (8.13.1/Vontu) with SMTP id l43EqW8g028158
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 09:52:32 -0500 (CDT)
Received: from tx14exm60.ds.mot.com (TX14EXM60.ftw.mot.com [10.63.147.60])
	by az33exr01.mot.com (8.13.1/8.13.0) with ESMTP id l43EqVHQ028151
	for <netdev@vger.kernel.org>; Thu, 3 May 2007 09:52:31 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <4637A0B1.20900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad,

Will these changes make it into the next Kernel release? If so which one
will it be?

Thanks,
Oscar 

-----Original Message-----
From: Vlad Yasevich [mailto:vladislav.yasevich@hp.com] 
Sent: Tuesday, May 01, 2007 3:19 PM
To: Isaula Oscar-QOI000
Cc: netdev@vger.kernel.org
Subject: Re: [SCTP] Initialization collision problem

Isaula Oscar-QOI000 wrote:
> Vlad,
> 
> I finally got test results for the changes you suggested. The original

> issue is fixed and I have not detected any side effects.

Thanks.

-vlad

> 
> Thanks,
> Oscar
> 
> -----Original Message-----
> From: netdev-owner@vger.kernel.org 
> [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Vlad Yasevich
> Sent: Wednesday, April 11, 2007 9:45 AM
> To: Isaula Oscar-QOI000
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [SCTP] Initialization collision problem
> 
> Hi Oscar
> 
> Isaula Oscar-QOI000 wrote:
>> I ran into a problem where LKSCTP is reporting a SCTM_COMM_UP 
>> indication to the User application but is giving back a value of zero

>> for the assoc_id.
>>
>> Attached are the SCTP debugs for the period in question.
>>
>> A couple of things that I would like to note about my setup. One is 
>> that I'm running Kernel version 2.6.10 (I know is old but I can't 
>> move
> 
>> to a newer version due to custom drivers). The second thing is that 
>> the link between the two SCTP node is a very noisy and some messages 
>> are getting lost (i.e. the INIT_ACK from the peer in this particular
> case).
> 
> Can you give this patch a try and let me know if this fixes your
issue?
> 
> Thanks
> -vlad
> 

