From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: [PATCH 06/11] drivers/net/bna: do not use EXTRA_CFLAGS
Date: Mon, 15 Aug 2011 01:16:59 -0400
Message-ID: <CACqU3MU7fvhVBZ3iEC=T7N57qx_=SvUgPO7W75NuefAL-h1EPg@mail.gmail.com>
References: <1313384834-24433-1-git-send-email-lacombar@gmail.com>
	<1313384834-24433-7-git-send-email-lacombar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaud Lacombe <lacombar@gmail.com>,
	Sam Ravnborg <sam@ravnborg.org>,
	Rasesh Mody <rmody@brocade.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:55896 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab1HOFRA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 01:17:00 -0400
In-Reply-To: <1313384834-24433-7-git-send-email-lacombar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, Aug 15, 2011 at 1:07 AM, Arnaud Lacombe <lacombar@gmail.com> wr=
ote:
> Usage of these flags has been deprecated for nearly 4 years by:
>
> =A0 =A0commit f77bf01425b11947eeb3b5b54685212c302741b8
> =A0 =A0Author: Sam Ravnborg <sam@neptun.(none)>
> =A0 =A0Date: =A0 Mon Oct 15 22:25:06 2007 +0200
>
> =A0 =A0 =A0 =A0kbuild: introduce ccflags-y, asflags-y and ldflags-y
>
> Moreover, these flags (at least EXTRA_CFLAGS) have been documented fo=
r command
> line use. By default, gmake(1) do not override command line setting, =
so this is
> likely to result in build failure or unexpected behavior.
>
> Replace their usage by Kbuild's `{as,cc,ld}flags-y'.
>
> Cc: Sam Ravnborg <sam@ravnborg.org>
> Cc: Rasesh Mody <rmody@brocade.com>
> Cc: netdev@vger.kernel.org
Signed-off-by: Arnaud Lacombe <lacombar@gmail.com>

 - Arnaud

> ---
> =A0drivers/net/bna/Makefile | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/bna/Makefile b/drivers/net/bna/Makefile
> index a5d604d..babc25f 100644
> --- a/drivers/net/bna/Makefile
> +++ b/drivers/net/bna/Makefile
> @@ -8,4 +8,4 @@ obj-$(CONFIG_BNA) +=3D bna.o
> =A0bna-objs :=3D bnad.o bnad_ethtool.o bna_ctrl.o bna_txrx.o
> =A0bna-objs +=3D bfa_ioc.o bfa_ioc_ct.o bfa_cee.o cna_fwimg.o
>
> -EXTRA_CFLAGS :=3D -Idrivers/net/bna
> +ccflags-y :=3D -Idrivers/net/bna
> --
> 1.7.6.153.g78432
>
>
