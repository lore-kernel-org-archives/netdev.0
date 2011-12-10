From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Optimizing tc filters
Date: Sat, 10 Dec 2011 16:01:46 -0500
Message-ID: <1323550906.3159.183.camel@denise.theartistscloset.com>
References: <1323540988.3159.133.camel@denise.theartistscloset.com>
	 <1323546064.4016.27.camel@edumazet-laptop>
	 <1323547080.3159.153.camel@denise.theartistscloset.com>
	 <1323547801.4016.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:54891 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab1LJVBu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 16:01:50 -0500
In-Reply-To: <1323547801.4016.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-12-10 at 21:10 +0100, Eric Dumazet wrote:
> Le samedi 10 d=C3=A9cembre 2011 =C3=A0 14:58 -0500, John A. Sullivan =
III a =C3=A9crit :
>=20
> > If we are using connection tracking in general to produce a "statef=
ul"
> > firewall (let's just say we are - I certainly don't want to set off=
 a
> > debate :) ), does that put #1 back on top as the most efficient sin=
ce we
> > are incurring the conntrack overhead anyway or does the CONNMARK ta=
rget
> > itself add considerable overhead? Thanks - John
> >=20
>=20
> CONNMARK is very cheap, no extra overhead.
>=20
>=20
OK - so I'll assume that, if using conntrac anyway, the order of
efficiency is as I outlined and, if not, #1 sinks to the bottom.  If
that's not accurate, please let me know.  Thanks for your help - John
