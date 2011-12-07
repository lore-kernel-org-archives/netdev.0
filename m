From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c: don't
 munge MAC address from platform data
Date: Wed, 7 Dec 2011 17:14:42 +0800
Message-ID: <20111207091441.GF5550@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <55b78c1766da5b0d0d679f5eae3fb9fc74a6ceef.1323163127.git.LW@KARO-electronics.de>
 <20111207084953.GD5550@S2100-06.ap.freescale.net>
 <20191.10281.826050.193987@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20191.10281.826050.193987@ipc1.ka-ro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 07, 2011 at 09:47:37AM +0100, Lothar Wa=DFmann wrote:
> Hi,
>=20
> Shawn Guo writes:
> > On Tue, Dec 06, 2011 at 11:27:13AM +0100, Lothar Wa=DFmann wrote:
> > > When the MAC address is supplied via platform_data it should be O=
K as
> > > it is and should not be modified in case of a dual FEC setup.
> > > Also copying the MAC from platform_data to the single 'macaddr'
> > > variable will overwrite the MAC for the first interface in case o=
f a
> > > dual FEC setup.
> >=20
> > Hmm, I do not follow that.  If 'macaddr' holds a valid mac address,
> > the code path has no chance to be hit at all.  Otherwise, 'macaddr'
> > is just a place holder for copying mac address from pdata, in which
> > case the mac address will be fixed up at the end of the function fo=
r
> > dual FEC setup.
> >=20
> In case of dual FEC and MAC address provided by platform_data the
> first mac address will be copied to the 'macaddr' variable with no
> chance for the second interface to get its mac address assigned from
> platform_data too.
>=20
Indeed.  So again other than subject,

Acked-by: Shawn Guo <shawn.guo@linaro.org>

--=20
Regards,
Shawn
