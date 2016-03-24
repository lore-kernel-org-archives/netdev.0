From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: Request 'reset' GPIO only for AT8030
 PHY
Date: Thu, 24 Mar 2016 11:10:48 +0100
Message-ID: <56F3BD28.4080908@laposte.net>
References: <56E99727.9040702@laposte.net> <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net> <20160318191242.GQ4292@pengutronix.de> <56EFEDAD.9030903@laposte.net> <20160321135457.GX4292@pengutronix.de> <56F0150F.8080804@laposte.net> <20160321201229.GA6191@pengutronix.de> <56F157EF.5080307@laposte.net> <20160322194224.GF6191@pengutronix.de> <56F26BF7.3090201@laposte.net> <56F274A5.6030502@laposte.net> <56F2F189.1030003@cogentembedded.com> <56F3B9A2.9060801@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	=?windows-1252?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz26.laposte.net ([194.117.213.101]:60271 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932078AbcCXKLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 06:11:00 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 224F311F31C
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:10:56 +0100 (CET)
Received: from lpn-prd-vrin004 (lpn-prd-vrin004.laposte [10.128.63.5])
	by lpn-prd-vrout014 (Postfix) with ESMTP id 8939A11F44C
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:10:49 +0100 (CET)
Received: from lpn-prd-vrin004 (localhost [127.0.0.1])
	by lpn-prd-vrin004 (Postfix) with ESMTP id 3AA5B70E2A9
	for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:10:49 +0100 (CET)
In-Reply-To: <56F3B9A2.9060801@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

>>    What I don't understand is why the link_change_notify() method ptr is
>> populated for all 3 supported chips while only being needed on 8030...
> 
> You are right.

I made the patch but I'm unsure about it because it could conflict with
yours.
I mean, I think you submitted a patch to change the GPIO handling on the
link_change_notify() function, right?

Well, if we only register the callback for the AT8030, then there is no
more need for the callback to check the PHY ID.
However, if I change that, the whole block moves as I remove one
indentation level (the one required by the PHY ID check).

Any suggestions on how to create a patch that won't conflict? I probably
need to use a tree that already has your patch applied.

Best regards,

Sebastian
