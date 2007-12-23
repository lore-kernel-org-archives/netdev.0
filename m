From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
	MAC address change
Date: Sun, 23 Dec 2007 07:46:15 -0500
Message-ID: <1198413975.4423.65.camel@localhost>
References: <31436f4a0712230341x5a0abf08q7e6f7917ba7e38f0@mail.gmail.com>
	 <20071223.211126.118866275.yoshfuji@linux-ipv6.org>
	 <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dshwatrz@gmail.com, davem@davemloft.net, netdev@vger.kernel.org,
	kaber@trash.net
To: YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:65361 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbXLWMq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 07:46:26 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1931732wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 04:46:25 -0800 (PST)
In-Reply-To: <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2007-23-12 at 21:38 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=
=E8=8B=B1=E6=98=8E wrote:
> In article <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.c=
om> (at Sun, 23 Dec 2007 14:24:00 +0200), "David Shwatrz" <dshwatrz@gma=
il.com> says:
>=20
> > Regarding your answer;  I accept it and I will soon send a revised
> > version of this patch (making changes to
> >  arp_netdev_event() and ndisc_netdev_event().)
> > I had  IPv4 in mind, there is no reason that it will no be also in =
IPv6.
>=20
> You should iterate all of ifa_list (for IPv4) / addr_list (for IPv6).
> For IPv6, we also have anycast (maintained by ac_list) as well.
>=20

Hrm, how is this going to work for the case of multiple MACs on a
device?=20
Changing one MAC address doesnt equate to issuing a grat arp with _the
new MAC_ for all ifa (given each MAC may be map to a different ifa)=20

cheers,
jamal

