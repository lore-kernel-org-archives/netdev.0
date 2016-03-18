From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 21:44:21 +0100
Message-ID: <56EC68A5.3050901@free.fr>
References: <56E99727.9040702@laposte.net>
 <20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
 <20160318191242.GQ4292@pengutronix.de> <56EC5788.3030509@free.fr>
 <20160318201153.GR4292@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sebastian Frias <sf84@laposte.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:5076 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754911AbcCRUor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 16:44:47 -0400
In-Reply-To: <20160318201153.GR4292@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18/03/2016 21:11, Uwe Kleine-K=F6nig wrote:

> Hello,
>=20
> On Fri, Mar 18, 2016 at 08:31:20PM +0100, Mason wrote:
>
>> On 18/03/2016 20:12, Uwe Kleine-K=F6nig wrote:
>>
>>> On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
>>>
>>>> What would you think of making at803x_link_change_notify() print a
>>>> message every time it should do a reset but does not has a way to =
do it?
>>>
>>> Then this question is obsolete because the device doesn't probe.
>>
>> I don't understand this statement.
>>
>> What does it mean for a question to be obsolete?
>=20
> If the driver doesn't probe because it cannot control the reset line,
> you don't need to think about how it should behave in
> at803x_link_change_notify without control of the reset line, because
> this code isn't reached then.

If I understand correctly, it is possible to soft-reset the PHY
by writing to a specific register. The GPIO pin is useful only to
force a hardware-reset when the PHY is wedged by some random event.

(Or am I completely off the mark?)

Regards.
