From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030
 PHY
Date: Thu, 24 Mar 2016 16:40:58 +0300
Message-ID: <56F3EE6A.5040304@cogentembedded.com>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net>
 <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net>
 <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net>
 <20160322194224.GF6191@pengutronix.de> <56F26BF7.3090201@laposte.net>
 <56F274A5.6030502@laposte.net> <56F2F189.1030003@cogentembedded.com>
 <56F3B9A2.9060801@laposte.net> <56F3BD28.4080908@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sebastian Frias <sf84@laposte.net>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56F3BD28.4080908@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/24/2016 01:10 PM, Sebastian Frias wrote:

>>>     What I don't understand is why the link_change_notify() method ptr is
>>> populated for all 3 supported chips while only being needed on 8030...
>>
>> You are right.
>
> I made the patch but I'm unsure about it because it could conflict with
> yours.
> I mean, I think you submitted a patch to change the GPIO handling on the
> link_change_notify() function, right?

> Well, if we only register the callback for the AT8030, then there is no
> more need for the callback to check the PHY ID.
> However, if I change that, the whole block moves as I remove one
> indentation level (the one required by the PHY ID check).
>
> Any suggestions on how to create a patch that won't conflict? I probably
> need to use a tree that already has your patch applied.

    My patch is already in Linus' tree, so should be merged back from net.git 
into net-next.git
soon. I suggest that you wait until net-next is open again.

> Best regards,
>
> Sebastian

MBR, Sergei
