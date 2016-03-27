From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers : Remove unnecessary void pointer conversions
Date: Sat, 26 Mar 2016 22:49:05 -0700
Message-ID: <1459057745.23450.17.camel@perches.com>
References: <1459050140-14621-1-git-send-email-njupudi@ucsc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Bhaskar Jupudi <njupudi@ucsc.edu>, davem@davemloft.net,
	igal.liberman@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459050140-14621-1-git-send-email-njupudi@ucsc.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-03-26 at 20:42 -0700, Bhaskar Jupudi wrote:
> Explicit void pointer conversion is unnecessary
> because the conversions to and from a void pointer
> are always implicit in 'C'. Changed two instances=A0
> of such conversions.

Your patch subject is incorrect, this is for fman
not all of drivers/

If you do one file, you should do them all.

$ git grep -E "\*\s*\)\s*of_get_property" drivers/net/ethernet/freescal=
e/
drivers/net/ethernet/freescale/fman/fman.c:=A0=A0=A0=A0=A0u32_prop =3D =
(const u32 *)of_get_property(fm_node, "cell-index", &lenp);
drivers/net/ethernet/freescale/fman/fman.c:=A0=A0=A0=A0=A0u32_prop =3D =
(const u32 *)of_get_property(fm_node,
drivers/net/ethernet/freescale/fman/fman_port.c:=A0=A0=A0=A0=A0=A0=A0=A0=
u32_prop =3D (const u32 *)of_get_property(port_node, "cell-index", &len=
p);
drivers/net/ethernet/freescale/fman/fman_port.c:=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0u32_prop =3D (const u32 *)of_get_property(port_=
node,
drivers/net/ethernet/freescale/fman/fman_port.c:=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0u32_prop =3D (const u32 *)of_get_property(port_=
node,
drivers/net/ethernet/freescale/fman/mac.c:=A0=A0=A0=A0=A0=A0char_prop =3D=
 (const char *)of_get_property(mac_node,

> =A0drivers/net/ethernet/freescale/fman/fman.c | 4 ++--
