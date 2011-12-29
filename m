From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH][NET] several cleanups and bugfixes for fec.c
Date: Thu, 29 Dec 2011 15:14:08 +0800
Message-ID: <20111229071407.GA11474@S2100-06.ap.freescale.net>
References: <cover.1323163127.git.LW@KARO-electronics.de>
 <4EFC0AE4.6020608@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>,
	<netdev@vger.kernel.org>, Shawn Guo <shawn.guo@linaro.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Dirk Behme <dirk.behme@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4EFC0AE4.6020608@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 29, 2011 at 07:38:28AM +0100, Dirk Behme wrote:
> On 06.12.2011 11:27, Lothar Wa=C3=9Fmann wrote:
> >The following set of patches provides some cleanup and bugfixes for
> >drivers/net/ethernet/freescale/fec.c and makes the driver buildable =
as
> >a module.
> >
> >Lothar Wa=C3=83=C5=B8mann (8):
> >   misc cleanups
> >   set con_id in clk_get() call to NULL
> >   prevent dobule restart of interface on FDX/HDX change
> >   don't request invalid IRQ
> >   don't munge MAC address from platform data
> >   preserve MII/RMII setting in fec_stop()
> >   fix the .remove code
> >   make FEC driver buildable as module
> >
> >  drivers/net/ethernet/freescale/Kconfig |    2 +-
> >  drivers/net/ethernet/freescale/fec.c   |   63 ++++++++++++++++++++=
++----------
> >  2 files changed, 44 insertions(+), 21 deletions(-)
>=20
> What's the status of this patch series?
>=20
> If I remember correctly, most of them got an Ack or Tested-by from
> Shawn? But one or two need an update (not sure, though)? And the
> subject should be updated?
>=20
The series with update has been picked up by David on net-next.
The LAKML was just missed from the updated posting.

--=20
Regards,
Shawn
