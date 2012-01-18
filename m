From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: route problem
Date: Wed, 18 Jan 2012 10:27:44 +0100
Message-ID: <1326878864.2316.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:51593 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757028Ab2ARJ1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 04:27:49 -0500
Received: by lahc1 with SMTP id c1so2061664lah.19
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 01:27:48 -0800 (PST)
In-Reply-To: <B97B134FACB2024DB45F524AB0A7B7F2058B01D4@XMB-BGL-419.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 janvier 2012 =C3=A0 14:47 +0530, Prashant Batra (prbatra=
) a
=C3=A9crit :
> Hi,
>=20
> I have added a route for an external ip via a gateway which is availa=
ble
> on the same machine.
> I want to capture the packets going to this external IP using PF_PACK=
ET
> socket.
>=20
> #route=20
> Destination     Gateway         Genmask         Flags Metric Ref    U=
se
> Iface
> 192.168.101.0   *               255.255.255.0   U     0      0       =
 0
> eth1
> 172.16.60.0     192.168.101.10  255.255.255.0   UG    0      0       =
 0
> eth1
>=20
> So, when a packet is sent to 172.16.60.*, kernel should send arp requ=
est
> for this gw IP 192.168.101.10. As gw IP is locally reachable,=20
> It should send its mac address in arp-response and kernel should send
> the packet via that interface.
>=20
> But what I am seeing is that instead of asking the gateway IP, kernel
> sends a arp request for destingation ip(172.16.60.*)
>=20
> #tcpdump -I eth1
> 04:12:45.334966 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:46.334839 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:48.334584 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:49.334457 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:50.335329 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:52.335075 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:53.334947 arp who-has 172.16.60.2 tell 192.168.101.20
> 04:12:54.334821 arp who-has 172.16.60.2 tell 192.168.101.20
>=20

Redirect problem ?

Please post=20

uname -a
ip ro list cache
