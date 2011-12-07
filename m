From: =?utf-8?Q?Lothar_Wa=C3=9Fmann?= <LW@KARO-electronics.de>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Wed, 7 Dec 2011 09:47:37 +0100
Message-ID: <20191.10281.826050.193987@ipc1.ka-ro>
References: <cover.1323163127.git.LW@KARO-electronics.de>
	<55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
	<20111207084953.GD5550@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111207084953.GD5550@S2100-06.ap.freescale.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Shawn Guo writes:
> On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=C3=9Fmann wrote:
> > When the MAC address is supplied via platform_data it should be OK =
as
> > it is and should not be modified in case of a dual FEC setup.
> > Also copying the MAC from platform_data to the single 'macaddr'
> > variable will overwrite the MAC for the first interface in case of =
a
> > dual FEC setup.
>=20
> Hmm, I do not follow that.  If 'macaddr' holds a valid mac address,
> the code path has no chance to be hit at all.  Otherwise, 'macaddr'
> is just a place holder for copying mac address from pdata, in which
> case the mac address will be fixed up at the end of the function for
> dual FEC setup.
>=20
In case of dual FEC and MAC address provided by platform_data the
first mac address will be copied to the 'macaddr' variable with no
chance for the second interface to get its mac address assigned from
platform_data too.


Lothar Wa=C3=9Fmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=C3=9Fe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=C3=A4ftsf=C3=BChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
