From: Karsten Keil <kkeil@linux-pingi.de>
Subject: Re: [PATCH] mISDN: Fix wrong usage of flush_work_sync while holding
 locks
Date: Thu, 13 Sep 2012 21:50:49 +0200
Message-ID: <50523919.9080701@linux-pingi.de>
References: <1347546980-15923-1-git-send-email-keil@b1-systems.de> <20120913.145937.235693485700301637.davem@davemloft.net> <20120913.150659.17331564270446673.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: keil@b1-systems.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:49942 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424Ab2IMTuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 15:50:54 -0400
In-Reply-To: <20120913.150659.17331564270446673.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 13.09.2012 21:06, schrieb David Miller:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 13 Sep 2012 14:59:37 -0400 (EDT)
> 
>> From: Karsten Keil <keil@b1-systems.de>
>> Date: Thu, 13 Sep 2012 16:36:20 +0200
>>
>>> It is a bad idea to hold a spinlock and call flush_work_sync.
>>> Move the workqueue cleanup outside the spinlock and use cancel_work_sync,
>>> on closing the channel this seems to be the more correct function.
>>> Remove the never used and constant return value of mISDN_freebchannel.
>>>
>>> Signed-off-by: Karsten Keil <keil@b1-systems.de>
>>> Cc: <stable@kernel.org>
>>
>> Applied, thanks.
> 
> BTW, about -stable:
> 
> 1) Even if it were appropriate to submit this directly to -stable,
>    stable@kernel.org is not the correct email address and you must
>    have seen the bounce produced by trying to send email there.
> 
>    Rather, stable@vger.kernel.org is the correct address.
> 
> 2) I queue up and submit networking bug fixes for -stable myself so
>    you should not submit them directly but rather make a request that
>    I add your patch to my networking -stable queue.
> 

OK, then I will put something like, "Should be considered for stable
too" in the comment and do not add the CC: stable@vger.kernel.org
for the next time.

Thanks.
