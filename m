From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v7 6/8] net: can: c_can: Disable pins when CAN interface
 is down
Date: Fri, 14 Nov 2014 18:04:47 +0200
Message-ID: <5466281F.3020609@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-7-git-send-email-rogerq@ti.com> <5464CCFF.5010004@ti.com> <5466225D.2070202@ti.com> <54662493.5040002@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>, <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <54662493.5040002@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/14/2014 05:49 PM, Marc Kleine-Budde wrote:
> On 11/14/2014 04:40 PM, Roger Quadros wrote:
>> DRA7 CAN IP suffers from a problem which causes it to be prevented
>> from fully turning OFF (i.e. stuck in transition) if the module was
>> disabled while there was traffic on the CAN_RX line.
>>
>> To work around this issue we select the SLEEP pin state by default
>> on probe and use the DEFAULT pin state on CAN up and back to the
>> SLEEP pin state on CAN down.
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
> 
> Wow! Some interations later this patch got quite nice and shiny :)
> Applied all to can-next/master.

Thanks Marc :)

cheers,
-roger

