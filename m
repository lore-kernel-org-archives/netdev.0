From: Craig Magina <craig.magina@canonical.com>
Subject: Re: sky2 negotiating only 100Mb/s (88E8055)
Date: Tue, 9 Jul 2013 13:31:15 +0000 (UTC)
Message-ID: <loom.20130709T152120-983@post.gmane.org>
References: <CACna6ry1z1LS9wMDb9dYyM+9z8kEpZADXKHL0NNoAahbm8wbNg@mail.gmail.com> <CACna6ryokPsaKVQmrF3ACmy99k3LiaOiZai5xrWdVjaxLWT80w@mail.gmail.com> <64925882.QA6f4ZcyAO@mlindner-lin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:39296 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753542Ab3GINkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jul 2013 09:40:09 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UwY9D-0002Lx-HY
	for netdev@vger.kernel.org; Tue, 09 Jul 2013 15:40:04 +0200
Received: from 173-166-109-13-newengland.hfc.comcastbusiness.net ([173.166.109.13])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 15:40:03 +0200
Received: from craig.magina by 173-166-109-13-newengland.hfc.comcastbusiness.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 15:40:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mirko Lindner <mlindner <at> marvell.com> writes:

>=20
> This is the first time somebody is reporting a problem with the=20
autoneg/speed=20
> initialization so I would like to check it in the lab.
>=20
> Mirko
>=20
> On Friday, March 15, 2013 05:03:01 AM Rafa=C5=82 Mi=C5=82ecki wrote:
> > 2013/3/3 Rafa=C5=82 Mi=C5=82ecki <zajec5 <at> gmail.com>:
> >=20
> > > I've problems with my:
> > > 08:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> > > 88E8055 PCI-E Gigabit Ethernet Controller [11ab:4363] (rev 13)
> > > using 3.4.28 kernel on my Sony notebook.
> > >

> > >
> > > sky2 0000:08:00.0: eth0: disabling interface
> > > sky2: driver version 1.30
> > > sky2 0000:08:00.0: Yukon-2 EC Ultra chip revision 3
> > > sky2 0000:08:00.0: irq 47 for MSI/MSI-X
> > > sky2 0000:08:00.0: eth0: addr 00:1d:ba:19:9e:db
> > > sky2 0000:08:00.0: eth0: enabling interface
> > > sky2 0000:08:00.0: eth0: Link is up at 100 Mbps, full duplex, flo=
w=20
control
> > > both


I can confirm this issue.

lspci: 03:00.0 Ethernet controller: Marvell Technology Group Ltd. Yukon=
=20
Optima 88E8059 [PCIe Gigabit Ethernet Controller with AVB] (rev 11)

sky2 0000:03:00.0 eth0: Link is up at 100 Mbps, full duplex, flow contr=
ol=20
both

My kernel version is Ubuntu 3.8.0-26.38 amd64, sky2 version 1.30.

~
Craig
