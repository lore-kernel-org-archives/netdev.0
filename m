From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 09:56:49 -0400
Message-ID: <9e4733910709190656w3e979191mcd0d0776d46283cf@mail.gmail.com>
References: <20070810095153.GC13994@moe.telargo.com>
	 <20070902074143.GB2642@nd47.coderock.org>
	 <fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
	 <20070915121444.GA19857@nd47.coderock.org>
	 <20070917095334.GA4546@powerlinux.fr>
	 <20070917202140.GB2642@nd47.coderock.org>
	 <9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
	 <20070918151622.GD32628@nd47.coderock.org>
	 <9e4733910709181229m4afe7ecr56e2411f52a84232@mail.gmail.com>
	 <BLU106-W49D16A32DDFE2611E15371CAB90@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Domen Puncer" <domen@coderock.org>, netdev@vger.kernel.org,
	linuxppc-embedded@ozlabs.org
To: "Pedro Luis D. L." <carcadiz@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:55571 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879AbXISN4v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:56:51 -0400
Received: by wa-out-1112.google.com with SMTP id v27so238216wah
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2007 06:56:50 -0700 (PDT)
In-Reply-To: <BLU106-W49D16A32DDFE2611E15371CAB90@phx.gbl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/19/07, Pedro Luis D. L. <carcadiz@hotmail.com> wrote:
>
> Hello Jon,
> I=B4m also working with a Phytec pcm030, but I can=B4t get it booted.=
=2E.
> Which kernel are you using?
> I tried to apply the 7 bestcomm patches from Sylvain and patch over t=
hese with this new ones that Domen released.
> The base kernel I=B4m using is 2.6.22.6 from kernel.org.
> Although I used the patch that creates pcm030.c in arch/platforms/52x=
x/ and compiled using this file, it gets halted at booting time.
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

The root name of your device tree needs to match the name in  pcm030.c
pcm030_probe(void). If they don't match this happens.

--=20
Jon Smirl
jonsmirl@gmail.com
