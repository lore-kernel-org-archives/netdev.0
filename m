From: "Pedro Luis D. L." <carcadiz@hotmail.com>
Subject: RE: [PATCH] phy: export phy_mii_ioctl
Date: Wed, 19 Sep 2007 10:54:39 +0200
Message-ID: <BLU106-W335FC371C9CDF56DA33F54CAB90@phx.gbl>
References: <20070810095153.GC13994@moe.telargo.com>
	<20070902074143.GB2642@nd47.coderock.org>
 	<fa686aa40709030857j6c36c87ek60215f812864ee0f@mail.gmail.com>
 	<20070915121444.GA19857@nd47.coderock.org>
 	<20070917095334.GA4546@powerlinux.fr>
 	<20070917202140.GB2642@nd47.coderock.org>
 	<9e4733910709171508s76c842c8hca236249617cbb44@mail.gmail.com>
 	<20070918151622.GD32628@nd47.coderock.org>
 <9e4733910709181229m4afe7ecr56e2411f52a84232@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linuxppc-embedded@ozlabs.org>
To: Jon Smirl <jonsmirl@gmail.com>, Domen Puncer <domen@coderock.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s16.bay0.hotmail.com ([65.54.246.152]:35463 "EHLO
	bay0-omc2-s16.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755064AbXISIyl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 04:54:41 -0400
In-Reply-To: <9e4733910709181229m4afe7ecr56e2411f52a84232@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello Jon,
I=B4m also working with a Phytec pcm030, but I can=B4t get it booted...
Which kernel are you using?
I tried to apply the 7 bestcomm patches from Sylvain and patch over the=
se with this new ones that Domen released.
The base kernel I=B4m using is 2.6.22.6 from kernel.org.
Although I used the patch that creates pcm030.c in arch/platforms/52xx/=
 and compiled using this file, it gets halted at booting time.

Bytes transferred =3D 5091 (13e3 hex)
## Booting image at 00500000 ...
   Image Name:   Linux-2.6.22.6
   Created:      2007-09-19   8:53:02 UTC
   Image Type:   PowerPC Linux Kernel Image (gzip compressed)
   Data Size:    1196911 Bytes =3D  1.1 MB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK
   Booting using flat device tree at 0x400000

(No more output and boot is halted)


Are you using any other patch for the platform or any other kernel, bec=
ause I tried to apply these patches to a 2.6.20 kernel and are not succ=
essful.

Bests,
Pedro.


> Date: Tue, 18 Sep 2007 15:29:09 -0400> From: jonsmirl@gmail.com=20
> To: domen@coderock.org> Subject: Re: [PATCH] phy: export phy_mii_ioct=
l=20
> CC: netdev@vger.kernel.org; linuxppc-embedded@ozlabs.org=20
>> On 9/18/07, Domen Puncer  wrote:=20
>> More testing and getting it to work properly on Phytec pcm030 would=20
>> be great.>> Do we want to do anything about this?=20
>> [ 1.569657] net eth0: attached phy 0 to driver Generic PHY=20
> [ 2.576013] Sending DHCP requests .PHY: f0003000:00 - Link is Up=20
> - 100/Full> [ 4.612000] ., OK=20
> [ 6.764005] IP-Config: Got DHCP answer from 192.168.1.200, my=20
> address is 192.168.1.5
>> What is happening is the printk for "PHY: f0003000:00 - Link is Up=20
> - 100/Full" is done in an interrupt and it comes in the middle of the=
> kernel doing DHCP and printing ... without a CR.=20
>> Two possible solutions, get rid of the link-up message or wait in in=
=20
> the initial driver load until the link is up. Or we could leave it th=
e=20
> way it is, but some people may report this as a bug.
>>> --> Jon Smirl> jonsmirl@gmail.com=20
> _______________________________________________=20
> Linuxppc-embedded mailing list> Linuxppc-embedded@ozlabs.org> https:/=
/ozlabs.org/mailman/listinfo/linuxppc-embedded

_________________________________________________________________
Busca desde cualquier p=E1gina Web con una protecci=F3n excepcional. Co=
nsigue la Barra de herramientas de Windows Live hoy mismo y GRATUITAMEN=
TE.
http://www.toolbar.live.com