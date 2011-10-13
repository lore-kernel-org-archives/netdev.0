From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] be2net: fix truesize errors
Date: Thu, 13 Oct 2011 18:32:33 +0200
Message-ID: <1318523553.2393.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1318523462.2393.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42880 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135Ab1JMQcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:32:17 -0400
Received: by wwf22 with SMTP id 22so2058545wwf.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 09:32:16 -0700 (PDT)
In-Reply-To: <1318523462.2393.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 18:31 +0200, Eric Dumazet a =C3=A9crit =
:
> Fix skb truesize underestimations of this driver.
>=20
> Each frag truesize is exactly rx_frag_size bytes. (2048 bytes per
> default)
>=20
> A driver should not use "sizeof(struct sk_buff)" at all.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet>

Oh well, garbled Signed-off-by, sorry !

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
