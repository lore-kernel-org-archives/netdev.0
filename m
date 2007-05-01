From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP] Initialization collision problem
Date: Tue, 01 May 2007 16:18:57 -0400
Message-ID: <4637A0B1.20900@hp.com>
References: <5F14EEE91CB6694A86535A0A028D9C5501555FEF@tx14exm60.ds.mot.com> <461CF473.7010307@hp.com> <5F14EEE91CB6694A86535A0A028D9C55016AEDF2@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Isaula Oscar-QOI000 <Oscar.Isaula@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:54359 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbXEAUS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 16:18:59 -0400
In-Reply-To: <5F14EEE91CB6694A86535A0A028D9C55016AEDF2@tx14exm60.ds.mot.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
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
>> that I'm running Kernel version 2.6.10 (I know is old but I can't move
> 
>> to a newer version due to custom drivers). The second thing is that 
>> the link between the two SCTP node is a very noisy and some messages 
>> are getting lost (i.e. the INIT_ACK from the peer in this particular
> case).
> 
> Can you give this patch a try and let me know if this fixes your issue?
> 
> Thanks
> -vlad
> 

