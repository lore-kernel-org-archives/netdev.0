From: "David S. Miller" <davem@davemloft.net>
Subject: Re: udp.c
Date: Mon, 13 Jun 2005 14:57:16 -0700 (PDT)
Message-ID: <20050613.145716.88477054.davem@davemloft.net>
References: <20050613.124515.104034144.davem@davemloft.net>
	<E1Dhwho-0001mn-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261435AbVFMWDS@vger.kernel.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1Dhwho-0001mn-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 14 Jun 2005 07:42:52 +1000

> It'll dump the stack anyway if we just make it a NULL pointer.

Some platforms don't handle that very cleanly, for example
it may be necessary to have something mapped at page zero
for one reason or another.
