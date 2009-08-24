From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH] sit: 6to4: honour routing table
Date: Mon, 24 Aug 2009 08:37:08 +0200
Message-ID: <3324b33c97aa3dba56e96b187db30042@chewa.net>
References: <1250938072-5577-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sascha Hlusiak <contact@saschahlusiak.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40904 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbZHXGhH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 02:37:07 -0400
In-Reply-To: <1250938072-5577-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 22 Aug 2009 12:47:52 +0200, Sascha Hlusiak=0D
<contact@saschahlusiak.de> wrote:=0D
> Using only the actual destination address to determine the IPv4 targe=
t in=0D
> try_6to4(&iph6->daddr) seems wrong to me and breaks, if a 6to4 addres=
s is=0D
> the next-hop, like ::192.88.99.1 written as 6to4:=0D
> =0D
> default via 2002:c058:6301:: dev 6to4=0D
> =0D
> A package to 2001:: would fall through the try_6to4 check to the=0D
> IPv4-compat check and die there.=0D
=0D
I don't understand what you're trying to fix. For a 6to4 tunnel, this h=
as=0D
always worked fine for me, as far as I remember:=0D
default via ::192.88.99.1 dev 6to4=0D
=0D
> This patch makes try_6to4 use the address of the Next-Hop instead,=0D
> respecting=0D
> the routing table. Users are encouraged to have a route 2002::/16 to =
the=0D
> tunnel device anyway, making all other 6to4 hosts direct neighbours.=0D
=0D
And where exactly is that "encouragement" coming from?=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

