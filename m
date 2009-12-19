From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return
 value against zero
Date: Fri, 18 Dec 2009 20:32:09 -0800 (PST)
Message-ID: <20091218.203209.229747361.davem@davemloft.net>
References: <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de>
	<1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
	<4B292DDE.6080906@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: u.kleine-koenig@pengutronix.de, linux-kernel@vger.kernel.org,
	dvrabel@arcom.com, gregkh@suse.de, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, kurt.van.dijck@eia.be,
	netdev@vger.kernel.org
To: wg@grandegger.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756131AbZLSEcN@vger.kernel.org>
In-Reply-To: <4B292DDE.6080906@grandegger.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Wolfgang Grandegger <wg@grandegger.com>
Date: Wed, 16 Dec 2009 19:58:38 +0100

> Uwe Kleine-K=F6nig wrote:
>> platform_get_irq returns -ENXIO on failure, so !irq was probably
>> always true.  Better use (int)irq <=3D 0.  Note that a return value =
of
>> zero is still handled as error even though this could mean irq0.
>>=20
>> This is a followup to 305b3228f9ff4d59f49e6d34a7034d44ee8ce2f0 that
>> changed the return value of platform_get_irq from 0 to -ENXIO on err=
or.
>>=20
>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
>=20
> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

Applied, thanks.
