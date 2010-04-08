From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] udp: fix for unicast RX path optimization
Date: Thu, 08 Apr 2010 17:12:27 +0200
Message-ID: <1270739547.2215.61.camel@edumazet-laptop>
References: <4BBDEEB0.7060003@dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: jorge@dti2.net, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39963 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754922Ab0DHPMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:12:32 -0400
Received: by bwz1 with SMTP id 1so1866746bwz.21
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 08:12:31 -0700 (PDT)
In-Reply-To: <4BBDEEB0.7060003@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 avril 2010 =C3=A0 16:56 +0200, Jorge Boncompte [DTI2] a =C3=
=A9crit :
> 	Commits 5051ebd275de672b807c28d93002c2fb0514a3c9 and
> 5051ebd275de672b807c28d93002c2fb0514a3c9 ("ipv[46]: udp: optimize uni=
cast RX
> path") broke some programs.
>=20
> 	After upgrading a L2TP server to 2.6.33 it started to fail, tunnels =
going up an
> down, after the 10th tunnel came up. My modified rp-l2tp uses a globa=
l
> unconnected socket bound to (INADDR_ANY, 1701) and one connected sock=
et per
> tunnel after parameter negotiation.
>=20
> 	After ten sockets were open and due to mixed parameters to
> udp[46]_lib_lookup2() kernel started to drop packets.
>=20
> Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>

Oops...

Thank you for finding this bug, this is indeed the right fix.

This is a stable candidate. David, can you catch it even if Jorge didnt
sent you a copy ?

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


