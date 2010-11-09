From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Tue, 09 Nov 2010 06:22:32 +0100
Message-ID: <1289280152.2790.23.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Dangaard Brouer <jdb@comx.dk>,
	netdev <netdev@vger.kernel.org>
To: Andrew Hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37003 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab0KIFWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 00:22:43 -0500
Received: by wyb36 with SMTP id 36so4429971wyb.19
        for <netdev@vger.kernel.org>; Mon, 08 Nov 2010 21:22:42 -0800 (PST)
In-Reply-To: <AANLkTi=HhouZymj0R7JsDy-X1LDbfT_WL0x10EMhdOho@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 11:05 +1100, Andrew Hendry a =C3=A9cri=
t :
> results on an i7 860 @ 2.80Ghz machine, no virtualization involved. 2=
=2E6.37-rc1+
>=20
> # time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat  127.0.0.1 99=
99
> 10000+0 records in
> 10000+0 records out
> 10485760000 bytes (10 GB) copied, 50.2022 s, 209 MB/s
>=20
> real	0m50.210s
> user	0m1.094s
> sys	0m57.589s

Thanks !

Could you take a pef snapshot during the test ?

# perf record -a -g sleep 10
# perf report



