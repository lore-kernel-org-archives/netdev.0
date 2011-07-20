From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] skbuff: use kfree_skb() instead of kfree()
Date: Wed, 20 Jul 2011 09:42:03 +0200
Message-ID: <1311147723.3113.116.camel@edumazet-laptop>
References: <20110720072343.GF6445@shale.localdomain>
	 <20110720072549.GG6445@shale.localdomain>
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
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50275 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab1GTHpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 03:45:49 -0400
In-Reply-To: <20110720072549.GG6445@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 20 juillet 2011 =C3=A0 10:25 +0300, Dan Carpenter a =C3=A9c=
rit :
> Crap.  Sorry, I shouldn't have sent that.  We shouldn't return the
> freed "n" here.  I'll send a v2 shortly.

Also, dont forget to say its a patch for net-next-2.6

The recommended way is to use=20

[PATCH net-next-2.6] ...



