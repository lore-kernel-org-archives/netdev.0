From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Thu, 20 Oct 2011 00:34:58 -0400 (EDT)
Message-ID: <20111020.003458.1034042223691970343.davem@davemloft.net>
References: <CANP3RGf1ZyNEiADXMsD1C=4GMyOMvxEZQ93nYpghhXhCJKNF6Q@mail.gmail.com>
	<20111020.001939.548341110762997206.davem@davemloft.net>
	<CAHo-OoxYiqSOg6fPWWAaocF2L3DzyV_UFYT0CPRGVd7LNxDCwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bazsi@balabit.hu
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab1JTEfE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 00:35:04 -0400
In-Reply-To: <CAHo-OoxYiqSOg6fPWWAaocF2L3DzyV_UFYT0CPRGVd7LNxDCwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Wed, 19 Oct 2011 21:31:06 -0700

>> A process with CAP_NET_RAW can spit whatever crap they want onto the
>> network, and receive all packets with impunity.
>=20
> Agreed.  But it can do so via raw sockets, it cannot do so via normal
> udp/tcp/ip sockets.
> That's why I'd like to relax the permissions check on being able to
> switch a socket
> into transparent mode.  A process with CAP_NET_RAW can already pretty
> much emulate
> that behaviour by using raw sockets - it just can't do that using the
> higher level, often more
> usable/useful socket/protocol apis.
>=20
>> I can't see what this buys us at all, sorry.
>=20
> See above.

Ok, I'm convinced, send me that patch without the warning messages.

Thanks.
