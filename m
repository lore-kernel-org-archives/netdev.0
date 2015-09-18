From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [linux-next] Regression in net/ipv4/route.c
Date: Fri, 18 Sep 2015 03:57:19 -0700
Message-ID: <1442573839.7946.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150918101123.77d48b84@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>
To: Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33113 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559AbbIRK5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 06:57:21 -0400
Received: by pacex6 with SMTP id ex6so48878182pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 03:57:20 -0700 (PDT)
In-Reply-To: <20150918101123.77d48b84@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-18 at 10:11 +0200, Lothar Wa=C3=9Fmann wrote:

>=20
> I bisected it down to: commit b7503e0cdb5d (net: Add FIB table id to =
rtable)
>=20
> There may be other ways to produce the same crash too, but I did not
> test any further.
>=20
>=20
> Lothar Wa=C3=9Fmann

=46ixed with

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?=
id=3Dbde6f9ded1bd37ff27a042dcb968e104d92b02c1

Thanks Lothar
