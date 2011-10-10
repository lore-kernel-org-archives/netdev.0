From: David Lamparter <equinox@diac24.net>
Subject: Re: e100 + VLANs?
Date: Mon, 10 Oct 2011 12:19:54 +0200
Message-ID: <20111010101954.GB2840382@jupiter.n2.diac24.net>
References: <4E90212D.8030009@msgid.tls.msk.ru>
 <1318091046.5276.22.camel@edumazet-laptop>
 <4E9097C0.2030307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michael Tokarev <mjt@tls.msk.ru>,
	netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:56801 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097Ab1JJKUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Oct 2011 06:20:07 -0400
Content-Disposition: inline
In-Reply-To: <4E9097C0.2030307@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 08, 2011 at 11:34:40AM -0700, Jeff Kirsher wrote:
> On 10/08/2011 09:24 AM, Eric Dumazet wrote:
> > Le samedi 08 octobre 2011 =C3=A0 14:08 +0400, Michael Tokarev a =C3=
=A9crit :
> >> > Yesterday I tried to use 802.1Q VLAN tagging with an (oldish)
> >> > e100-driven network card, identified by lspci like this:
> >> >=20
> >> >  00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Et=
hernet Pro 100 (rev 02)
> >> >=20
> >> > Just to discover that it does not quite work: packets of
> >> > size 1497+ bytes gets lost.
[...]
> > e100 driver seems VLAN enabled at a first glance.
> Eric is correct, that e100 does support VLANs.
>=20
> In addition to Eric's suggestion, can you also provide all the output=
 of
> lspci -vvv for the network card?

I'm opening the lore box here, but early e100 cards AFAIK have a=20
hardware limit at 1500 (+18 src/dst/proto) bytes. At least, Juniper's
JUNOS does not support full-sized .1Q on their e100 control plane
interfaces...


-equi
