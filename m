From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH] net: RFC3069, private VLAN proxy arp support
Date: Wed, 06 Jan 2010 11:28:19 +0100
Message-ID: <4B4465C3.9090403@gmail.com>
References: <20100105155047.13309.79610.stgit@firesoul.comx.local>	 <4B4427CE.1040203@gmail.com> <1262771369.9474.80.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34122 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604Ab0AFK2Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 05:28:24 -0500
In-Reply-To: <1262771369.9474.80.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 10:49, Jesper Dangaard Brouer a =C3=A9crit :

> This patch solved the issue by doing proxy arp'ing on the router agai=
nst
> the "local" network, thus making it possible for customers to
> communicate, but via the router.  This also gives the ability to do
> firewalling on the router between customers on an Ethernet. (In our
> solution the Linux router also have a personal firewall configurable =
per
> customer.)
>=20
> It is simply enabled on an interface via e.g.:
>=20
>  echo 1 > /proc/sys/net/ipv4/conf/eth2.1013/proxy_arp_pvlan
>=20
> Hope that helps your understand the idea and usage :-)
>=20

Excellent, thanks for sharing !
