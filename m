From: Juergen Beisert <jbe@pengutronix.de>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 12:37:59 +0200
Message-ID: <200709191238.00183.jbe@pengutronix.de>
References: <20070810095153.GC13994@moe.telargo.com> <9e4733910709181229m4afe7ecr56e2411f52a84232@mail.gmail.com> <BLU106-W49D16A32DDFE2611E15371CAB90@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Pedro Luis D. L." <carcadiz@hotmail.com>,
	Jon Smirl <jonsmirl@gmail.com>,
	Domen Puncer <domen@coderock.org>, netdev@vger.kernel.org
To: linuxppc-embedded@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:48145 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756169AbXISKiP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 06:38:15 -0400
In-Reply-To: <BLU106-W49D16A32DDFE2611E15371CAB90@phx.gbl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pedro,

On Wednesday 19 September 2007 10:54, Pedro Luis D. L. wrote:
> I=B4m also working with a Phytec pcm030, but I can=B4t get it booted.=
=2E.
> Which kernel are you using?
> I tried to apply the 7 bestcomm patches from Sylvain and patch over t=
hese
> with this new ones that Domen released. The base kernel I=B4m using i=
s
> 2.6.22.6 from kernel.org.
> Although I used the patch that creates pcm030.c in arch/platforms/52x=
x/ and
> compiled using this file, it gets halted at booting time.
>
> Bytes transferred =3D 5091 (13e3 hex)
> ## Booting image at 00500000 ...
>    Image Name:   Linux-2.6.22.6
>    Created:      2007-09-19   8:53:02 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    1196911 Bytes =3D  1.1 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
>    Uncompressing Kernel Image ... OK
>    Booting using flat device tree at 0x400000
>
> (No more output and boot is halted)

Check your oftree! Most of the time this behaviour means its a wrong of=
tree in=20
use.

Juergen

--=20
Dipl.-Ing. Juergen Beisert | http://www.pengutronix.de
=A0Pengutronix - Linux Solutions for Science and Industry
=A0   Handelsregister: Amtsgericht Hildesheim, HRA 2686
=A0 =A0 =A0    Vertretung Sued/Muenchen, Germany
   Phone: +49-8766-939 228 |  Fax: +49-5121-206917-9
