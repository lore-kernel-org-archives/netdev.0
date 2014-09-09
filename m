From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 1/3] can: c_can_platform: Fix c_can_hw_raminit_ti()
 and add timeout
Date: Tue, 9 Sep 2014 17:39:52 +0300
Message-ID: <540F1138.3090502@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-2-git-send-email-rogerq@ti.com> <540F0FDD.60201@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <tony@atomide.com>, <tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<nm@ti.com>, <sergei.shtylyov@cogentembedded.com>,
	<linux-omap@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <540F0FDD.60201@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/2014 05:34 PM, Marc Kleine-Budde wrote:
> On 09/09/2014 04:31 PM, Roger Quadros wrote:
>> Pass the correct 'mask' and 'value' bits to c_can_hw_raminit_wait_ti().
>> They seem to have been swapped in the usage instances.
> 
> Can you split this fix into a seperate patch, please.

OK.

> 
>> TI's RAMINIT DONE mechanism is buggy and may not always be
>> set after the START bit is set. So add a timeout mechanism to
>> c_can_hw_raminit_wait_ti().
> 
> What should happen if the timeout occurs?

I'm not sure yet. I will verify if the hardware still works or not in that case.
If it doesn't work then we should fail.

cheers,
-roger
