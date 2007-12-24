From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6][NEIGH] Updating affected neighbours when about
	MAC address change
Date: Mon, 24 Dec 2007 09:33:20 -0500
Message-ID: <1198506800.9642.40.camel@localhost>
References: <31436f4a0712230424n1cfaeb27o463e62093af41090@mail.gmail.com>
	 <20071223.213841.108421688.yoshfuji@linux-ipv6.org>
	 <1198413975.4423.65.camel@localhost>
	 <20071223.220447.56355925.yoshfuji@linux-ipv6.org>
	 <1198415873.4423.96.camel@localhost>
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
Received: from wa-out-1112.google.com ([209.85.146.176]:63676 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751958AbXLXOdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 09:33:25 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2719871wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 06:33:25 -0800 (PST)
In-Reply-To: <1198415873.4423.96.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2007-23-12 at 08:17 -0500, jamal wrote:
> On Sun, 2007-23-12 at 22:04 +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=97=
=A4=E8=8B=B1=E6=98=8E wrote:
>=20
> > If the secondary MACs are used with ARP/NDP, we should take care of
> > that, but I think we use the primary MAC for ARP/NDP, no?
> > (In other words, we always use primary MAC for ARP reply / NA, no?)
>=20
> I think it maybe a policy decision;=20

Never mind, that was my body being in a different time zone.
I went back and looked at a little chat i had with Patrick when he
posted with the macvlan driver.
At the moment we are still maintaining the model that a NIC can _only_
appear to have a single MAC to the upper layers. IOW, you have to
instantiate a macvlan device for each of the 16 MAC addresses on the
e1000 if you need to expose them. This means that the ip layer - even
with multiple ip addresses will only ever see one MAC address.=20
Note also: The name macvlan is a little misleading since it allows for
the above without need for vlans.

cheers,
jamal




