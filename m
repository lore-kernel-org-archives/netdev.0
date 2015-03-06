From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/7] soc/fman: Add the FMan FLIB headers
Date: Fri, 6 Mar 2015 10:32:18 -0600
Message-ID: <6250951C-902C-49D3-9730-756EE611AF3B@kernel.crashing.org>
References: <1425534351-1065-1-git-send-email-Emilian.Medve@Freescale.com> <1425534351-1065-2-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Igal Liberman <Igal.Liberman@freescale.com>
To: Emil Medve <Emilian.Medve@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:54697 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750979AbbCFQcp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 11:32:45 -0500
In-Reply-To: <1425534351-1065-2-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 4, 2015, at 11:45 PM, Emil Medve <Emilian.Medve@freescale.com> w=
rote:

> From: Igal Liberman <Igal.Liberman@freescale.com>
>=20
> The Freescale Data Path Acceleration Architecture (DPAA) is a set of
> hardware components on specific QorIQ P and T series multicore proces=
sors.
> This architecture provides the infrastructure to support simplified
> sharing of networking interfaces and accelerators by multiple CPU cor=
es,
> and the accelerators themselves.
>=20
> One of the DPAA accelerators is the Frame Manager (FMan), which
> combines the Ethernet network interfaces with packet distribution
> logic to provide intelligent distribution and queuing decisions for
> incoming traffic at line rate.
>=20
> This patch presents the FMan Foundation Libraries (FLIB) headers.
> The FMan FLIB suite adds basic support for the DPAA FMan hardware reg=
ister access.
> The FMan FLIB suite is used in Freescale's SDK Releases.
>=20
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
> drivers/soc/fsl/fman/flib/common/general.h         |   45 +
> drivers/soc/fsl/fman/flib/fman_common.h            |   74 ++
> drivers/soc/fsl/fman/flib/fsl_enet.h               |  276 ++++++
> drivers/soc/fsl/fman/flib/fsl_fman.h               |  801 +++++++++++=
++++
> drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h         | 1017 +++++++++++=
+++++++++
> drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h |  104 ++
> drivers/soc/fsl/fman/flib/fsl_fman_kg.h            |  506 ++++++++++
> drivers/soc/fsl/fman/flib/fsl_fman_memac.h         |  492 ++++++++++
> drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h |   77 ++
> drivers/soc/fsl/fman/flib/fsl_fman_port.h          |  602 +++++++++++=
+
> drivers/soc/fsl/fman/flib/fsl_fman_prs.h           |  106 ++
> drivers/soc/fsl/fman/flib/fsl_fman_rtc.h           |  415 ++++++++
> drivers/soc/fsl/fman/flib/fsl_fman_sp.h            |  133 +++
> drivers/soc/fsl/fman/flib/fsl_fman_tgec.h          |  484 ++++++++++
> 14 files changed, 5132 insertions(+)
> create mode 100644 drivers/soc/fsl/fman/flib/common/general.h
> create mode 100644 drivers/soc/fsl/fman/flib/fman_common.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_enet.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_dtsec.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_dtsec_mii_acc.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_kg.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_memac.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_memac_mii_acc.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_port.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_prs.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_rtc.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_sp.h
> create mode 100644 drivers/soc/fsl/fman/flib/fsl_fman_tgec.h

1. this is way to big of patch to reasonable review
2. can some of these headers be associated with the code patches that u=
se them instead

>=20
> diff --git a/drivers/soc/fsl/fman/flib/common/general.h b/drivers/soc=
/fsl/fman/flib/common/general.h
> new file mode 100644
> index 0000000..e5f56af
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/flib/common/general.h
> @@ -0,0 +1,45 @@
> +/*
> + * Copyright 2008-2015 Freescale Semiconductor Inc.
> + *
> + * Redistribution and use in source and binary forms, with or withou=
t
> + * modification, are permitted provided that the following condition=
s are met:
> + *     * Redistributions of source code must retain the above copyri=
ght
> + *       notice, this list of conditions and the following disclaime=
r.
> + *     * Redistributions in binary form must reproduce the above cop=
yright
> + *       notice, this list of conditions and the following disclaime=
r in the
> + *       documentation and/or other materials provided with the dist=
ribution.
> + *     * Neither the name of Freescale Semiconductor nor the
> + *       names of its contributors may be used to endorse or promote=
 products
> + *       derived from this software without specific prior written p=
ermission.
> + *
> + *
> + * ALTERNATIVELY, this software may be distributed under the terms o=
f the
> + * GNU General Public License ("GPL") as published by the Free Softw=
are
> + * Foundation, either version 2 of that License or (at your option) =
any
> + * later version.
> + *
> + * THIS SOFTWARE IS PROVIDED BY Freescale Semiconductor ``AS IS'' AN=
D ANY
> + * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE=
 IMPLIED
> + * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOS=
E ARE
> + * DISCLAIMED. IN NO EVENT SHALL Freescale Semiconductor BE LIABLE F=
OR ANY
> + * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIA=
L DAMAGES
> + * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS O=
R SERVICES;
> + * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER =
CAUSED AND
> + * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY=
, OR TORT
> + * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE=
 USE OF THIS
> + * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> + */
> +
> +#ifndef __GENERAL_H
> +#define __GENERAL_H
> +
> +#include <linux/types.h>
> +#include <linux/io.h>
> +
> +#define UNUSED(X)	(X =3D X)

Don=92t we already have a kernel mechanism to mark something unused for=
 gcc to be quiet?

> +#define KILOBYTE	0x400UL	/* 1024 */

Really? I saw one usage, in which you could easily do (5 * 1024).

> +
> +#define iowrite32be(val, addr)		out_be32(&(*addr), val)
> +#define ioread32be(addr)		in_be32(&(*addr))
> +
> +#endif /* __GENERAL_H */

- k