From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net/fec: Don't let ndo_start_xmit return NETDEV_TX_BUSY
 without link
Date: Thu, 1 Aug 2013 02:01:05 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015E3A69@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1375176580-7368-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<20130730.160530.831845971567683172.davem@davemloft.net>
	<20130731081649.GA1754@pengutronix.de>
 <20130731.115101.340503855490269301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	"hector.palacios@digi.com" <hector.palacios@digi.com>,
	"tim.sander@hbm.com" <tim.sander@hbm.com>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"florian@openwrt.org" <florian@openwrt.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	"u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0188.outbound.messaging.microsoft.com ([213.199.154.188]:2197
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752810Ab3HACBZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 22:01:25 -0400
In-Reply-To: <20130731.115101.340503855490269301.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 01, 2013 at 02:51 AM, David Miller wrote:

>> On Tue, Jul 30, 2013 at 04:05:30PM -0700, David Miller wrote:
>>> From: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>>> Date: Tue, 30 Jul 2013 11:29:40 +0200
>>>=20
>>> > Don't test for having link and let hardware deal with this situat=
ion.
>>> >=20
>>> > Without this patch I see a machine running an -rt patched Linux=20
>>> > being stuck in sch_direct_xmit when it looses link while there is=
=20
>>> > still a packet to be sent. In this case the fec_enet_start_xmit=20
>>> > routine returned NETDEV_TX_BUSY which makes the network stack=20
>>> > reschedule the packet and so sch_direct_xmit calls fec_enet_start=
_xmit again.
>>> > I failed to reproduce a complete hang without -rt, but I think th=
e=20
>>> > problem exists there, too.
>>> >=20
>>> > Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de=
>
>>>=20
>>> Applied, thanks.
>> Thanks, I see it as a264b981f2c76e281ef27e7232774bf6c54ec865 in=20
>> net.git (i.e.
>> https://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?i=
d=3D
>> a264b981f2c76e281ef27e7232774bf6c54ec865)
>>=20
>> You missed to take the
>>=20
>> 	Acked-and-tested-by: Fugang Duan <B38611@freescale.com>
>
> This is not an official tag recognized by patchwork, he should say:
>
> Acked-by: Fugang Duan <B38611@freescale.com>
> Tested-by: Fugang Duan <B38611@freescale.com>

I see Linux kernel trees have many non-official tag such as: Acked-and-=
tested-by.
Anyway, we must follow the official rules. Thanks, David.
