From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net/cpsw: don't disable_irqs() after an interrupt has
 been received.
Date: Wed, 17 Apr 2013 14:16:29 +0530
Message-ID: <516E6165.8050908@ti.com>
References: <1366136460-30732-1-git-send-email-bigeasy@linutronix.de> <516E3EED.4000200@ti.com> <516E52EC.60901@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:35386 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965777Ab3DQIqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 04:46:42 -0400
In-Reply-To: <516E52EC.60901@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/17/2013 1:14 PM, Sebastian Andrzej Siewior wrote:
>> I have tested this patch and it hangs the CPU after net open (CPSW init).
> If I remove additionally the napi_schedule() piece then the network is
> dead (as expected) and the system continues to work (and I receive
> interrupts) and the ISR for cpsw is not executed again. What hardware /
> CPU do you have?
>
I am testing on Beagle Bone black.

Regards
Mugunthan V N
