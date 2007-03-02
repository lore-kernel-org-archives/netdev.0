From: Pascal GREGIS <pgs@synerway.com>
Subject: Re: need some help on a backport of r8169
Date: Fri, 2 Mar 2007 10:09:40 +0100
Message-ID: <20070302090940.GA27062@venus.synerway.com>
References: <20070226170941.GA17587@venus.synerway.com> <20070226234831.GA12830@electric-eye.fr.zoreil.com> <20070227110243.GA15657@venus.synerway.com> <20070227212400.GA12760@electric-eye.fr.zoreil.com> <20070228160133.GA8014@venus.synerway.com> <20070228230807.GB23772@electric-eye.fr.zoreil.com> <20070301095711.GC22482@venus.synerway.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.synerway.com ([84.14.10.249]:38829 "EHLO
	stargate.synerway.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933286AbXCBJJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 04:09:46 -0500
Received: from kamino.synerway.com (kamino [172.16.1.21])
	by stargate.synerway.com (Postfix) with ESMTP id 7E1E575C172
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2007 10:45:07 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20070301095711.GC22482@venus.synerway.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pgs@synerway.com a =E9crit, le Thu 01 Mar 2007 =E0 10:57:11AM :
> Hello Ueimor,
> [...]=20
> > Once you have logged the ifconfig/ethtool dump, you can try the ser=
ie
> > or the patch at:
> >=20
> > http://www.fr.zoreil.com/people/francois/backport/r8169/20070228-00
> Hum... ok I might have enough time to check it, not sure though, I
> have a point with my boss this morning.
Indeed I wasn't able to test it yesterday. I won't be able today so,
the hardware being required for other tests, but don't worry, I don't
forget you, I'll test it as soon as I can, probably next week.

>=20
> >=20
> > Btw:
> >=20
> > [...dmesg dump...]
> > > Enabling fast FPU save and restore... done.
> > > Enabling unmasked SIMD FPU exception support... done.
> > > Checking 'hlt' instruction... OK.
> > > ACPI: setting ELCR to 0200 (from 0c08)
> > > NET: Registered protocol family 16
> > > PCI: PCI BIOS revision 3.00 entry at 0xf0031, last bus=3D2
> > > PCI: Using MMCONFIG
> >=20
> > Please disable MMCONFIG.
> In the BIOS?
>=20
> >=20
> > If you have any PCI latency option in your bios, set it to 64.
> I'm not the BIOS-master, I'll suggest it.
>=20
> >=20
> > --=20
> > Ueimor
>=20
> Sigerg
