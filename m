From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: fix truesize errors
Date: Thu, 13 Oct 2011 16:06:02 -0400 (EDT)
Message-ID: <20111013.160602.718959925143893792.davem@davemloft.net>
References: <1318523462.2393.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1318523553.2393.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754113Ab1JMUGJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 16:06:09 -0400
In-Reply-To: <1318523553.2393.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Oct 2011 18:32:33 +0200

> Le jeudi 13 octobre 2011 =E0 18:31 +0200, Eric Dumazet a =E9crit :
>> Fix skb truesize underestimations of this driver.
>>=20
>> Each frag truesize is exactly rx_frag_size bytes. (2048 bytes per
>> default)
>>=20
>> A driver should not use "sizeof(struct sk_buff)" at all.
>>=20
>> Signed-off-by: Eric Dumazet <eric.dumazet>
>=20
> Oh well, garbled Signed-off-by, sorry !
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

:-)  Applied.
