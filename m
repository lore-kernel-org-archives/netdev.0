From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: route problem
Date: Wed, 18 Jan 2012 11:15:23 +0100
Message-ID: <1326881723.2316.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
	 <1326878864.2316.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <B97B134FACB2024DB45F524AB0A7B7F2058B020A@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:41085 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757193Ab2ARKP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 05:15:28 -0500
Received: by lahc1 with SMTP id c1so2089918lah.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 02:15:27 -0800 (PST)
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2058B020A@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 15:38 +0530, Prashant Batra (prbatra=
) a
=C3=A9crit :
> 2.6.18 kernel.
>=20

Please dont top post on netdev mailing list

> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Wednesday, January 18, 2012 2:58 PM
> To: Prashant Batra (prbatra)
> Cc: netdev@vger.kernel.org
> Subject: Re: route problem
>=20
> Le mercredi 18 janvier 2012 =C3=A0 14:47 +0530, Prashant Batra (prbat=
ra) a
> =C3=A9crit :
> > Hi,
> >=20
> > I have added a route for an external ip via a gateway which is avai=
lable
> > on the same machine.
> > I want to capture the packets going to this external IP using PF_PA=
CKET
> > socket.
> >=20
> > #route=20
> > Destination     Gateway         Genmask         Flags Metric Ref   =
 Use
> > Iface
> > 192.168.101.0   *               255.255.255.0   U     0      0     =
   0
> > eth1
> > 172.16.60.0     192.168.101.10  255.255.255.0   UG    0      0     =
   0
> > eth1
> >=20
> > So, when a packet is sent to 172.16.60.*, kernel should send arp re=
quest
> > for this gw IP 192.168.101.10. As gw IP is locally reachable,=20
> > It should send its mac address in arp-response and kernel should se=
nd
> > the packet via that interface.
> >=20
> > But what I am seeing is that instead of asking the gateway IP, kern=
el
> > sends a arp request for destingation ip(172.16.60.*)
> >=20
> > #tcpdump -I eth1
> > 04:12:45.334966 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:46.334839 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:48.334584 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:49.334457 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:50.335329 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:52.335075 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:53.334947 arp who-has 172.16.60.2 tell 192.168.101.20
> > 04:12:54.334821 arp who-has 172.16.60.2 tell 192.168.101.20
> >=20

This comes from another machine, since your eth1 addr is 192.168.101.10
