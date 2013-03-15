From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: sky2 negotiating only 100Mb/s (88E8055)
Date: Fri, 15 Mar 2013 08:35:20 -0700
Message-ID: <20130315083520.72c1fd49@nehalam.linuxnetplumber.net>
References: <CACna6ry1z1LS9wMDb9dYyM+9z8kEpZADXKHL0NNoAahbm8wbNg@mail.gmail.com>
	<CACna6ryokPsaKVQmrF3ACmy99k3LiaOiZai5xrWdVjaxLWT80w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Mirko Lindner <mlindner@marvell.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:45853 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754767Ab3COPfb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 11:35:31 -0400
Received: by mail-pb0-f50.google.com with SMTP id up1so3934286pbc.23
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 08:35:30 -0700 (PDT)
In-Reply-To: <CACna6ryokPsaKVQmrF3ACmy99k3LiaOiZai5xrWdVjaxLWT80w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Mar 2013 13:03:01 +0100
Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:

> 2013/3/3 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> > I've problems with my:
> > 08:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd.
> > 88E8055 PCI-E Gigabit Ethernet Controller [11ab:4363] (rev 13)
> > using 3.4.28 kernel on my Sony notebook.
> >
> > I've tried connecting it to the:
> > 1) HP#1 (Intel card)
> > 2) HP#2 (Broadcom card)
> > 3) Router based on BCM4706 with BCM53125 switch
> > I've tried two different CAT5e cables for all the above devices. In
> > every case sky2 established 100Mbps link only. It couldn't achieve
> > 1000Mb/s. Forcing it to 1000Mbps broke link. Lower speeds (100 half
> > duplex and 10 Mbps) are working fine.
> >
> > It's not the issue with the cable or devices, because all other
> > configurations are working fine. I can connect:
> > 1) HP#1 with HP#2
> > 2) HP#1 with router
> > 3) HP#2 with router
> > and I always get 1000Mbps.
> >
> > So it looks like some bugged hardware or (more likely?) issue in sk=
y2.
> >
> > sky2 0000:08:00.0: eth0: disabling interface
> > sky2: driver version 1.30
> > sky2 0000:08:00.0: Yukon-2 EC Ultra chip revision 3
> > sky2 0000:08:00.0: irq 47 for MSI/MSI-X
> > sky2 0000:08:00.0: eth0: addr 00:1d:ba:19:9e:db
> > sky2 0000:08:00.0: eth0: enabling interface
> > sky2 0000:08:00.0: eth0: Link is up at 100 Mbps, full duplex, flow =
control both
> >
> > Can you help me with that?


PHY stuff is black magic, and sometimes vendors break things outside
the driver. You might check for a BIOS update? Does it work with window=
s?
