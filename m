From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] bnx2x: fix crash during TSO tunneling
Date: Thu, 24 Jul 2014 23:44:33 -0700 (PDT)
Message-ID: <20140724.234433.554868671962785328.davem@davemloft.net>
References: <1406217287-4069-1-git-send-email-Dmitry.Kravkov@qlogic.com>
	<1406219874.3363.71.camel@edumazet-glaptop2.roam.corp.google.com>
	<87B4DDAD5EAFA041BDC28F314593782D01802C27@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, dkravkov@gmail.com, netdev@vger.kernel.org,
	ypei@redhat.com, mschmidt@redhat.com
To: Dmitry.Kravkov@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbaGYGoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:44:34 -0400
In-Reply-To: <87B4DDAD5EAFA041BDC28F314593782D01802C27@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Date: Thu, 24 Jul 2014 21:48:34 +0000

> 
>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Thursday, July 24, 2014 7:38 PM
>> To: Dmitry Kravkov
>> Cc: netdev; David Miller; ypei@redhat.com; mschmidt@redhat.com; Dmitry
>> Kravkov
>> Subject: Re: [PATCH RESEND] bnx2x: fix crash during TSO tunneling
>> 
>> On Thu, 2014-07-24 at 18:54 +0300, Dmitry Kravkov wrote:
>> > From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
>> >
>> > When TSO packet is transmitted additional BD w/o mapping is used to
>> > describe the packed. The BD needs special handling in tx completion.
 ...
>> > Reported-by: Yulong Pei <ypei@redhat.com>
>> > Cc: Michal Schmidt <mschmidt@redhat.com>
>> > Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
>> > ---
>> 
>> How old is this bug ? Can you point original commit adding it ?
>> 
>> Thanks !
>>
> Added with initial TSO support for tunneling back in 3.10 with
> a848ade408b6bfab59d575d6c246efb20afe88e3 
> "bnx2x: add CSUM and TSO support for encapsulation protocols"
> and can be seen only with *_iommu=on

Applied with an ppropriate "Fixes: " tag added, and queued up for
-stable.

Thanks.
