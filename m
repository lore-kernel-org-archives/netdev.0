From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6 v2] skbuff: fix error handling in
 pskb_copy()
Date: Thu, 21 Jul 2011 14:48:08 -0700 (PDT)
Message-ID: <20110721.144808.175750981188812579.davem@davemloft.net>
References: <20110720072343.GF6445@shale.localdomain>
	<20110720085149.GI6445@shale.localdomain>
	<1311152386.2338.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: error27@gmail.com, xma@us.ibm.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799Ab1GUVtQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 17:49:16 -0400
In-Reply-To: <1311152386.2338.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jul 2011 10:59:46 +0200

> Le mercredi 20 juillet 2011 =E0 11:51 +0300, Dan Carpenter a =E9crit =
:
>> There are two problems:
>> 1) "n" was allocated with alloc_skb() so we should free it with
>>    kfree_skb() instead of regular kfree().
>> 2) We return the freed pointer instead of NULL.
>>=20
>> Signed-off-by: Dan Carpenter <error27@gmail.com>
>=20
> Thanks Dan
>=20
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
