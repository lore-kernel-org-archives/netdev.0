From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH net-next 2/2] net: ethernet: Initial driver for Synopsys
 DWC XLGMAC
Date: Wed, 7 Dec 2016 10:48:15 +0100
Message-ID: <20161207094815.GB5399@amd>
References: <cover.1481075763.git.jiedeng@synopsys.com>
 <3fe82457c51f8437797eae27d03cdb0dcbef039b.1481075763.git.jiedeng@synopsys.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="QKdGvSO+nmPlgiQ/"
Cc: davem@davemloft.net, f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, CARLOS.PALMINHA@synopsys.com,
        lars.persson@axis.com, thomas.lendacky@amd.com
To: Jie Deng <Jie.Deng1@synopsys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3fe82457c51f8437797eae27d03cdb0dcbef039b.1481075763.git.jiedeng@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--QKdGvSO+nmPlgiQ/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> This patch provides the initial driver for 25/40/50/100 GbE
> devices using Synopsys DWC Enterprise Ethernet (XLGMAC)
>=20
> Signed-off-by: Jie Deng <jiedeng@synopsys.com>

I trust this is different hardware from stmmac?

> diff --git a/MAINTAINERS b/MAINTAINERS
> index 331f6af..738f818 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -10639,6 +10639,12 @@ S: Supported
>  F: Documentation/devicetree/bindings/net/snps,dwc-qos-ethernet.txt
>  F: drivers/net/ethernet/synopsys/dwc_eth_qos.c
> =20
> +SYNOPSYS DESIGNWARE ENTERPRISE ETHERNET (XLGMAC) DRIVER
> +M:	jiedeng <jiedeng@synopsys.com>

Jie Deng here?


> @@ -0,0 +1,228 @@
> +/*
> + * Synopsys DesignWare Ethernet Driver

Your patch title names hardware differently...?


> + *
> + * Copyright (c) 2014-2016 Synopsys, Inc. (www.synopsys.com)
> + *
> + * This file is free software; you may copy, redistribute and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation, either version 2 of the License, or (at
> + * your option) any later version.
> + *
> + * This file is distributed in the hope that it will be useful, but
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
> + * General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program.  If not, see <http://www.gnu.org/licenses/>.
> + *
> + * This file incorporates work covered by the following copyright and
> + * permission notice:
> + *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
> + *     (hereinafter "Software") is an unsupported proprietary work of Sy=
nopsys,
> + *     Inc. unless otherwise expressly agreed to in writing between Syno=
psys
> + *     and you.
> + *
> + *     The Software IS NOT an item of Licensed Software or Licensed Prod=
uct
> + *     under any End User Software License Agreement or Agreement for Li=
censed
> + *     Product with Synopsys or any supplement thereto.  Permission is h=
ereby
> + *     granted, free of charge, to any person obtaining a copy of this s=
oftware
> + *     annotated with this license and the Software, to deal in the Soft=
ware
> + *     without restriction, including without limitation the rights to u=
se,
> + *     copy, modify, merge, publish, distribute, sublicense, and/or sell=
 copies
> + *     of the Software, and to permit persons to whom the Software is fu=
rnished
> + *     to do so, subject to the following conditions:
> + *
> + *     The above copyright notice and this permission notice shall be in=
cluded
> + *     in all copies or substantial portions of the Software.

> + *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS I=
S"
> + *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT L=
IMITED
> + *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
> + *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOP=
SYS
> + *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLAR=
Y, OR
> + *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT=
 OF
> + *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR B=
USINESS
> + *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHET=
HER IN
> + *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHE=
RWISE)
> + *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVIS=
ED OF
> + *     THE POSSIBILITY OF SUCH DAMAGE.

Are you sure this is GPL compatible? Can we get a version without this
lenghty legaleese?

Thanks,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--QKdGvSO+nmPlgiQ/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEUEARECAAYFAlhH2t8ACgkQMOfwapXb+vLvSgCgrTI4D5/R0QESgH1luk7VjiDJ
MdMAl3dixtzirbiavAQKR2idaqh50KI=
=5XM5
-----END PGP SIGNATURE-----

--QKdGvSO+nmPlgiQ/--
