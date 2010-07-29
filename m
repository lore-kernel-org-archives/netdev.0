From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: linux-next: manual merge of the net tree with the net-current
	tree
Date: Wed, 28 Jul 2010 18:26:54 -0700
Message-ID: <AANLkTimFauHpzYk4C3sW=o-k+9yJP0iz1kWKXE9Brnzn@mail.gmail.com>
References: <20100729111904.90b148a6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100729111904.90b148a6.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2010 at 18:19, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
> Hi all,
>
> Today's linux-next merge of the net tree got a conflict in
> drivers/net/e1000e/hw.h between commit
> ff847ac2d3e90edd94674c28bade25ae1e6a2e49 ("") from the net-current tr=
ee
> and commit d3738bb8203acf8552c3ec8b3447133fc0938ddd ("e1000e: initial
> support for 82579 LOMs") from the net tree.
>
> Just context changes. I fixed it up (see below) and can carry the fix=
 for
> a while.
> --
> Cheers,
> Stephen Rothwell =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0sfr@canb.auug.org.au
>
> diff --cc drivers/net/e1000e/hw.h
> index 664ed58,0cd569a..0000000
> --- a/drivers/net/e1000e/hw.h
> +++ b/drivers/net/e1000e/hw.h
> @@@ -308,8 -312,8 +312,8 @@@ enum e1e_registers
> =C2=A0#define E1000_KMRNCTRLSTA_INBAND_PARAM =C2=A0 =C2=A0 =C2=A0 =C2=
=A00x9 =C2=A0 =C2=A0/* Kumeran InBand Parameters */
> =C2=A0#define E1000_KMRNCTRLSTA_DIAG_NELPBK 0x1000 /* Nearend Loopbac=
k mode */
> =C2=A0#define E1000_KMRNCTRLSTA_K1_CONFIG =C2=A0 0x7
> =C2=A0-#define E1000_KMRNCTRLSTA_K1_ENABLE =C2=A0 0x140E
> =C2=A0+#define E1000_KMRNCTRLSTA_K1_ENABLE =C2=A0 0x0002
> - #define E1000_KMRNCTRLSTA_K1_DISABLE =C2=A00x1400
> + #define E1000_KMRNCTRLSTA_HD_CTRL =C2=A0 =C2=A0 0x0002
>
> =C2=A0#define IFE_PHY_EXTENDED_STATUS_CONTROL =C2=A0 =C2=A0 =C2=A0 0x=
10
> =C2=A0#define IFE_PHY_SPECIAL_CONTROL =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 0x11 /* 100BaseTx PHY Special Control */
> --

yes, that is fine and expected.  When Dave sync's up is net-next-2.6
tree with net-2.6 tree, this issue will be fixed up.

--=20
Cheers,
Jeff
