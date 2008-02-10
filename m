From: =?UTF-8?Q?Marcin_Koziej?= <marcinkoziej@o2.pl>
Subject: =?UTF-8?Q?[solved]_Re:_Bug=3F_Kernels_2.6.2x_drops_TCP_packets_over?=
	=?UTF-8?Q?_wireless_(independentofcard_used)?=
Date: Sun, 10 Feb 2008 02:00:14 +0100
Message-ID: <19f9d171.497edb0.47ae4c9e.87c28@o2.pl>
References: <56de948.2f1b076b.47aac980.bfd66@o2.pl> <47AB321E.5080908@cosmosbay.com> <5d83a64e.4ddf1deb.47ab4ef3.49eb3@o2.pl> <47AB5AD6.3010100@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Eric_Dumazet?= <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tur.go2.pl ([193.17.41.50]:45261 "EHLO tur.go2.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbYBJBCR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Feb 2008 20:02:17 -0500
Received: from rekin26.go2.pl (rekin26.go2.pl [193.17.41.76])
	by tur.go2.pl (o2.pl Mailer 2.0.1) with ESMTP id E9B3F2300E7
	for <netdev@vger.kernel.org>; Sun, 10 Feb 2008 02:02:15 +0100 (CET)
In-Reply-To: <47AB5AD6.3010100@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dnia 7 lutego 2008 20:24 Eric Dumazet <dada1@cosmosbay.com> napisa=C5=82=
(a):
> Typical window scaling problem here... (well, for previous traces, wi=
th=20
> wscaling of 5, since with wscale 2 it seems to work), you probably ha=
ve a=20
> buggy router or something...
>=20
> http://lwn.net/Articles/92727/
>=20
> Try :
>=20
> # echo 0 >/proc/sys/net/ipv4/tcp_window_scaling
>=20
> And retry to connect to this ftp server
>=20
> You could alternativly play with /proc/sys/net/ipv4/tcp_rmem
>=20
> # echo "4096 8192 50000" >/proc/sys/net/ipv4/tcp_rmem

Thanks! That solves the problem! Now I read about TCP window scaling an=
d I understand the issue, but I wouldn't figure/google that out myself!=
=20
Thank You for Your time!

m.

