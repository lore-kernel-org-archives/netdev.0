From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bnx2 is spamming dmesg
Date: Wed, 13 Oct 2010 23:36:48 +0200
Message-ID: <1287005808.2649.46.camel@edumazet-laptop>
References: <1287005434.8004.32.camel@keith-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: Keith Mannthey <kmannth@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63509 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab0JMVhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 17:37:10 -0400
Received: by wyb28 with SMTP id 28so1522676wyb.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 14:37:09 -0700 (PDT)
In-Reply-To: <1287005434.8004.32.camel@keith-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 octobre 2010 =C3=A0 14:30 -0700, Keith Mannthey a =C3=A9=
crit :
> Hello All,
>   For the last couple of months (since at least 2.6.35 somewhere) I h=
ave
> been seeing=20
>=20
> "
> ....
> [698612.423825] Device 0000:0b:00.0 unmapping: pfn ffc74-ffc74
> [698612.423831] Device 0000:0b:00.0 unmapping: pfn ff96d-ff96d
> [698612.639262] Device 0000:0b:00.0 unmapping: pfn ffc74-ffc74
> [698612.639269] Device 0000:0b:00.0 unmapping: pfn ff96d-ff96d
> ....
> "
> in my dmesg output. =20
>=20
> "
>  lspci -s 0000:0b:00.0
> 0b:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM570=
9
> Gigabit Ethernet (rev 20)
> "
>=20
> The bnx2 driver is loaded on my system.  I am presently on 2.6.36-rc3
> kernels but like I mentioned I have been seeing this for a while.
>=20
>=20
> Any ideas? I would rather not have this endless message in my kernel
> logs.=20
>=20

drivers/pci/intel-iommu.c line 2737

pr_debug("Device %s unmapping: pfn %lx-%lx\n",
	pci_name(pdev), start_pfn, last_pfn);

So you asked/activated some debugging, because pr_debug() is not defaul=
t
enabled...



