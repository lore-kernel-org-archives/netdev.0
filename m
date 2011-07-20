From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next-2.6 v2] skbuff: fix error handling in
 pskb_copy()
Date: Wed, 20 Jul 2011 10:59:46 +0200
Message-ID: <1311152386.2338.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110720072343.GF6445@shale.localdomain>
	 <20110720085149.GI6445@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shirley Ma <xma@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42686 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569Ab1GTI7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 04:59:55 -0400
In-Reply-To: <20110720085149.GI6445@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 11:51 +0300, Dan Carpenter a =C3=A9c=
rit :
> There are two problems:
> 1) "n" was allocated with alloc_skb() so we should free it with
>    kfree_skb() instead of regular kfree().
> 2) We return the freed pointer instead of NULL.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks Dan

Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>


