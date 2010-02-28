From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 10:13:51 +0100
Message-ID: <1267348431.9082.66.camel@edumazet-laptop>
References: <20100228.144537.445518512048328806.yamato@redhat.com>
	 <20100228.010057.229746532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:43364 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031637Ab0B1JN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:13:56 -0500
Received: by bwz1 with SMTP id 1so566010bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 01:13:54 -0800 (PST)
In-Reply-To: <20100228.010057.229746532.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 28 f=C3=A9vrier 2010 =C3=A0 01:00 -0800, David Miller a =C3=
=A9crit :
> From: Masatake YAMATO <yamato@redhat.com>
> Date: Sun, 28 Feb 2010 14:45:37 +0900 (JST)
>=20
> > The Inode field in /proc/net/{tcp,udp,packet,raw,...} is useful to =
know the types of=20
> > file descriptors associated to a process. Actually lsof utility use=
s the field.
> > Unfortunately, unlike /proc/net/{tcp,udp,packet,raw,...}, /proc/net=
/netlink doesn't have the field.
> > This patch adds the field to /proc/net/netlink.
> >=20
> > Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>=20
> Unfortunately we cannot add new fields without breaking the parsing
> done by existing applications.

Hmm we already did such expansion last year with commit 38938bfe when
Pablo Neira Ayuso added the Drops column

Extract of its Changelog :

 This patch also includes the use of sk_drop to account the number of
 netlink messages drop due to overrun. This value is shown in
 /proc/net/netlink.

So yes, some applications might break but they probably already broke
one year ago and their maintainers should know that adding new fields a=
t
the end of lines is expected ?

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks


