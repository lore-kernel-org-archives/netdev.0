From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 4/4] packet: Add pre-defragmentation support for ipv4
Date: Wed, 06 Jul 2011 08:20:40 -0700 (PDT)
Message-ID: <20110706.082040.1487690721120263418.davem@davemloft.net>
References: <1A61D8EA6755AF458F06EA669A4EC8182F05BCB0@JKLMAIL02.ixonos.local>
	<1309965489.2292.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mika.penttila@ixonos.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754Ab1GFPUp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:20:45 -0400
In-Reply-To: <1309965489.2292.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Jul 2011 17:18:09 +0200

> [PATCH] packet: fix a leak in fanout_check_defrag()
>=20
> Reported-by: Penttil=E4 Mika <mika.penttila@ixonos.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric, see what I commited, it's much simpler than all
of this code movement you added, ala skb_share_check()
:-)
