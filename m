From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ipv4: speedup inet_dump_ifaddr()
Date: Thu, 12 Nov 2009 20:14:37 +0100
Message-ID: <4AFC5E9D.9030103@gmail.com>
References: <4AFC1798.1060501@gmail.com>	<20091112091221.3d523253@nehalam>	<4AFC4979.7030007@gmail.com> <20091112111218.0a561166@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53923 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbZKLTOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 14:14:36 -0500
In-Reply-To: <20091112111218.0a561166@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =C3=A9crit :

>=20
> One case where that might happen is:
>   modprobe dummy numdummies=3D10000
>=20
> But dummy device should really be added with netlink, not at boot tim=
e.
>=20

At least we cannot exceed 32768 dummies :)
