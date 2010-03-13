From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Code paths setting gso_size
Date: Sat, 13 Mar 2010 13:09:02 +0100
Message-ID: <1268482142.2947.38.camel@edumazet-laptop>
References: <4B9B7591.9080706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Dan Carpenter <error27@gmail.com>,
	David Miller <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:65257 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab0CMMJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 07:09:08 -0500
Received: by bwz1 with SMTP id 1so1735984bwz.21
        for <netdev@vger.kernel.org>; Sat, 13 Mar 2010 04:09:06 -0800 (PST)
In-Reply-To: <4B9B7591.9080706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 13 mars 2010 =C3=A0 06:22 -0500, William Allen Simpson a =C3=A9=
crit :
> This is a new thread dedicated to a specific topic, spawned by an
> earlier discussion.  I've CC'd only those that participated recently.
>=20
> I've written:
> # In this particular instance, I suggest that you take a look at all =
the
> # places that gso_size is set, and cross index with all the code path=
s that
> # place these TCP headers onto the txq without a check of doff -- as =
I did!
> #
> # I'll specifically mention the tun and virtio_net devices, but I'm a=
lso
> # particularly concerned with af_packet.c and skbuff.c -- and the gen=
eral
> # problem with inet_lro.c, too.
> #
> # Amazingly enough, folks sometimes use Linux for routers....
> #
>=20
> Eric (and David) have written:
> # Only *locally* generated trafic by linux kernel can enter this path=
=2E
> #
>=20
> So, let us begin with the tun device, and work our way through the ot=
hers.
>=20

Thats a really good idea William, I'll start another thread to study al=
l
the paths setting skb->len to a possible wrong value. But I'll do this
in my own time, and if I find something, I'll post a patch.

Sure we'll find some bugs by this studies, since in average we find 100
bugs per month, and introduce 90 new ones, thanks God for this.



