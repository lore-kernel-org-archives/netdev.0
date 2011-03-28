From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] tg3: Don't use IRQF_SAMPLE_RANDOM
Date: Sun, 27 Mar 2011 18:38:56 -0700 (PDT)
Message-ID: <20110327.183856.200383919.davem@davemloft.net>
References: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
	<1301193753-10045-2-git-send-email-martinez.javier@gmail.com>
	<20110327030830.GF1885@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martinez.javier@gmail.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54536
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753235Ab1C1Bje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:39:34 -0400
In-Reply-To: <20110327030830.GF1885@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sun, 27 Mar 2011 06:08:30 +0300

> On Sun, Mar 27, 2011 at 04:42:32AM +0200, Javier Martinez Canillas wrote:
>> This flag is scheduled for removal so we shouldn't used it.
>> 
>> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
>> ---
>>  drivers/net/tg3.c |    5 ++---
>>  1 files changed, 2 insertions(+), 3 deletions(-)
>> 
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index c67eb19..58c6049 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -8844,12 +8844,11 @@ static int tg3_request_irq(struct tg3 *tp, int irq_num)
>>  		fn = tg3_msi;
>>  		if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI)
>>  			fn = tg3_msi_1shot;
>> -		flags = IRQF_SAMPLE_RANDOM;
> 
> You need initialize flags to zero here.  Apparently gcc doesn't catch
> this.  I'm using gcc 4.4.3-4ubuntu5.

Javier please fix this up and resubmit your patch.

Thanks.
