From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] act_nat: not all of the ICMP packets need an IP header
 payload
Date: Mon, 12 Jul 2010 20:02:12 -0700 (PDT)
Message-ID: <20100712.200212.235693051.davem@davemloft.net>
References: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
	<1278742953.2538.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, hadi@cyberus.ca, rpartearroyo@albentia.com,
	herbert@gondor.apana.org.au, ipichel@albentia.com,
	nmoron@albentia.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752442Ab0GMDB6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 23:01:58 -0400
In-Reply-To: <1278742953.2538.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Jul 2010 08:22:33 +0200

> Rodrigo spent lot of time to find the problem and is willing to fix i=
t.

I gave Rodrigo suitable credit in the final commit message.

--------------------
=46rom 70c2efa5a32a7d38e66224844032160317fa7887 Mon Sep 17 00:00:00 200=
1
=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 9 Jul 2010 15:33:25 +0000
Subject: [PATCH] act_nat: not all of the ICMP packets need an IP header=
 payload
MIME-Version: 1.0
Content-Type: text/plain; charset=3DUTF-8
Content-Transfer-Encoding: 8bit

not all of the ICMP packets need an IP header payload, so we check the =
length
of the skbs only when the packets should have an IP header payload.

Based upon analysis and initial patch by Rodrigo Partearroyo Gonz=E1lez=
=2E

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
--------------------
