From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 17:14:04 +0530
Message-ID: <516E8B04.3090102@ti.com>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com> <516E52EC.60901@linutronix.de> <516E6165.8050908@ti.com> <516E6538.8060804@linutronix.de> <516E7492.9090608@ti.com> <516E7E26.10603@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:41836 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966070Ab3DQLoU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 07:44:20 -0400
In-Reply-To: <516E7E26.10603@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/2013 4:19 PM, Sebastian Andrzej Siewior wrote:
> On 04/17/2013 12:08 PM, Mugunthan V N wrote:
>> Mine shows [    0.000000] AM335X ES2.0 (neon )
>>
>> In Beagle bone (silicon revision 1.0) there is a bug in CPSW irq in
>> Silicon, please refer
>> http://www.ti.com/lit/er/sprz360e/sprz360e.pdf  Advisory 1.0.9
>>
>> Beagle bone black has Silicon revision 2.0 where the bug is fixed and
>> you are able
>> to test it properly and it hangs in my bone black as the IRQ is properly
>> connected
>> to A8
> Okay. This would explain things. So let me try it again without
> breaking the new one. If you disable_irq() there is no need to mask the
> source in chip, right?
>
Yes, May be we can try. If the performance is more then we can think of 
removing
disabling interrupt in CPSW and use only disable ARM irq.

Regards
Mugunthan V N
