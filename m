From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] add a sysctl to disable TCP simultaneous connection opening
Date: Thu, 9 Oct 2008 23:42:24 +0200
Message-ID: <20081009214224.GD21013@1wt.eu>
References: <20081008081109.GA25342@1wt.eu> <20081008135402.7b837992@speedy> <200810091921.04230.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4683 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755179AbYJIVma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 17:42:30 -0400
Content-Disposition: inline
In-Reply-To: <200810091921.04230.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 07:21:03PM +0300, R=E9mi Denis-Courmont wrote:
> Le mercredi 8 octobre 2008 14:54:02 Stephen Hemminger, vous avez =E9c=
rit=A0:
> > Does this break NAT traversal via STUNT used by applications like S=
kype?
>=20
> This will break the main ICE-TCP mechanism (IETF draft-ietf-mmusic-ic=
e-tcp).
> I am not aware of any application using this _as_of_now_. Probably to=
o many=20
> NAT and firewall implementations will reject it already. And then, so=
me TCP=20
> stacks reportedly do not support it (e.g. Windows before Vista).

And opening this through firewalls would be too much dangerous as it wo=
uld
allow servers to reconnect outside, pretty much defeating the initial p=
urpose
of the firewall.

> On the other hand, if someone were to tunnel/encapsulate TCP over UDP=
, this=20
> could actually be useful - think about peer-to-peer NATted-to-NATted =
file=20
> transfers for instance.

This is already possible using netcat. You can force both ports. It has=
 no
flow control but would be enough to chat or transfer small config files=
=2E

Willy

