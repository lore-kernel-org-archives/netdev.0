From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Sat, 19 Mar 2016 10:01:44 +0000
Message-ID: <yw1xfuvm3hx3.fsf@unicorn.mansr.com>
References: <56E99727.9040702@laposte.net>
	<20160318125455.GN4292@pengutronix.de> <56EC2525.8000706@laposte.net>
	<20160318191242.GQ4292@pengutronix.de> <56EC5788.3030509@free.fr>
	<20160318201153.GR4292@pengutronix.de> <56EC68A5.3050901@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	Sebastian Frias <sf84@laposte.net>,
	Daniel Mack <daniel@zonque.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from unicorn.mansr.com ([81.2.72.234]:42217 "EHLO unicorn.mansr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752186AbcCSKBu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 06:01:50 -0400
In-Reply-To: <56EC68A5.3050901@free.fr> (Mason's message of "Fri, 18 Mar 2016
	21:44:21 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mason <slash.tmp@free.fr> writes:

> On 18/03/2016 21:11, Uwe Kleine-K=F6nig wrote:
>
>> Hello,
>>=20
>> On Fri, Mar 18, 2016 at 08:31:20PM +0100, Mason wrote:
>>
>>> On 18/03/2016 20:12, Uwe Kleine-K=F6nig wrote:
>>>
>>>> On Fri, Mar 18, 2016 at 04:56:21PM +0100, Sebastian Frias wrote:
>>>>
>>>>> What would you think of making at803x_link_change_notify() print =
a
>>>>> message every time it should do a reset but does not has a way to=
 do it?
>>>>
>>>> Then this question is obsolete because the device doesn't probe.
>>>
>>> I don't understand this statement.
>>>
>>> What does it mean for a question to be obsolete?
>>=20
>> If the driver doesn't probe because it cannot control the reset line=
,
>> you don't need to think about how it should behave in
>> at803x_link_change_notify without control of the reset line, because
>> this code isn't reached then.
>
> If I understand correctly, it is possible to soft-reset the PHY
> by writing to a specific register. The GPIO pin is useful only to
> force a hardware-reset when the PHY is wedged by some random event.

Yes, and some variants of this phy are broken and require a hard reset
in certain situations.  At least that's what the comment in the code
says.

--=20
M=E5ns Rullg=E5rd
