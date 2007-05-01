From: "Isaula Oscar-QOI000" <Oscar.Isaula@motorola.com>
Subject: RE: [SCTP] Initialization collision problem
Date: Tue, 1 May 2007 15:09:07 -0500
Message-ID: <5F14EEE91CB6694A86535A0A028D9C55016AEDF2@tx14exm60.ds.mot.com>
References: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com> <461CF473.7010307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Vlad Yasevich" <vladislav.yasevich@hp.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail128.messagelabs.com ([216.82.250.131]:42173 "HELO
	mail128.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753686AbXEAUJL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:09:11 -0400
Received: from az33exr01.mot.com (az33exr01.mot.com [10.64.251.231])
	by motgate2.mot.com (8.12.11/Motorola) with ESMTP id l41K9Ak6019935
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 13:09:10 -0700 (MST)
Received: from az10vts01 (az10vts01.mot.com [10.64.251.242])
	by az33exr01.mot.com (8.13.1/Vontu) with SMTP id l41K99Lj029553
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 15:09:10 -0500 (CDT)
Received: from tx14exm60.ds.mot.com (TX14EXM60.ftw.mot.com [10.63.147.60])
	by az33exr01.mot.com (8.13.1/8.13.0) with ESMTP id l41K98Kb029531
	for <netdev@vger.kernel.org>; Tue, 1 May 2007 15:09:09 -0500 (CDT)
Content-class: urn:content-classes:message
In-Reply-To: <461CF473.7010307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad,

I finally got test results for the changes you suggested. The original
issue is fixed and I have not detected any side effects.

Thanks,
Oscar 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Vlad Yasevich
Sent: Wednesday, April 11, 2007 9:45 AM
To: Isaula Oscar-QOI000
Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [SCTP] Initialization collision problem

Hi Oscar

Isaula Oscar-QOI000 wrote:
> I ran into a problem where LKSCTP is reporting a SCTM_COMM_UP 
> indication to the User application but is giving back a value of zero 
> for the assoc_id.
> 
> Attached are the SCTP debugs for the period in question.
> 
> A couple of things that I would like to note about my setup. One is 
> that I'm running Kernel version 2.6.10 (I know is old but I can't move

> to a newer version due to custom drivers). The second thing is that 
> the link between the two SCTP node is a very noisy and some messages 
> are getting lost (i.e. the INIT_ACK from the peer in this particular
case).
> 

Can you give this patch a try and let me know if this fixes your issue?

Thanks
-vlad
