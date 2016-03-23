From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Wed, 23 Mar 2016 11:55:14 +0100
Message-ID: <56F27612.7080001@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net> <20160322194224.GF6191@pengutronix.de> <56F26D27.3020106@free.fr> <56F27261.4060005@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56F27261.4060005@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On 03/23/2016 11:39 AM, Sergei Shtylyov wrote:
>>          gpiod_reset = devm_gpiod_get_optional(dev, "reset",
>> GPIOD_OUT_HIGH);
> 
>    We shouldn't call _optional() then, should we?

I could imagine the original intention was to be backward compatible.

Indeed, if this call is not optional, systems using AT8030 and lacking a
reset line on DT will have their behaviour affected.
NOTE: they would still work because even if this driver fails to bind a
generic one will take over.

Best regards,

Sebastian
