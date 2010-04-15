From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] drivers: net: use skb_headlen()
Date: Thu, 15 Apr 2010 04:44:04 +0200
Message-ID: <1271299444.16881.1766.camel@edumazet-laptop>
References: <1271191700.16881.574.camel@edumazet-laptop>
	 <20100414.155949.210580528.davem@davemloft.net>
	 <20100414.161504.149014877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:63768 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756542Ab0DOCoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Apr 2010 22:44:13 -0400
Received: by bwz25 with SMTP id 25so961284bwz.28
        for <netdev@vger.kernel.org>; Wed, 14 Apr 2010 19:44:12 -0700 (PDT)
In-Reply-To: <20100414.161504.149014877.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 avril 2010 =C3=A0 16:15 -0700, David Miller a =C3=A9crit=
 :

> Eric, there were several typos in this patch and it is clear
> that even e1000 wasn't build tested.
>=20
> You used the mystical "skb_headsize()" instead of "skb_headlen()"
> in several locations.
>=20
> I fixed this up, but please build test your changes no matter
> how seemingly trivial next time.
>=20

Oh well, I was sure I build tested it on a modallconfig, but now I
realize it was on a custom config, sorry David, thanks !


