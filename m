From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 4/4] packet: Add pre-defragmentation support for ipv4
Date: Wed, 06 Jul 2011 17:27:57 +0200
Message-ID: <1309966077.2292.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1A61D8EA6755AF458F06EA669A4EC8182F05BCB0@JKLMAIL02.ixonos.local>
	 <1309965489.2292.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110706.082040.1487690721120263418.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mika.penttila@ixonos.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36198 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab1GFP2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 11:28:11 -0400
Received: by wyg8 with SMTP id 8so30300wyg.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 08:28:10 -0700 (PDT)
In-Reply-To: <20110706.082040.1487690721120263418.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 juillet 2011 =C3=A0 08:20 -0700, David Miller a =C3=A9cr=
it :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 06 Jul 2011 17:18:09 +0200
>=20
> > [PATCH] packet: fix a leak in fanout_check_defrag()
> >=20
> > Reported-by: Penttil=C3=A4 Mika <mika.penttila@ixonos.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Eric, see what I commited, it's much simpler than all
> of this code movement you added, ala skb_share_check()
> :-)

I tried to not lose the original packet and let application catch it ;)

We probably need to add some atomic_inc(&sk->sk_drops) to at least warn
the application.



