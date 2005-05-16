From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in
 ip*_push_pending_frames
Date: Sun, 15 May 2005 17:32:42 -0700 (PDT)
Message-ID: <20050515.173242.125899783.davem@davemloft.net>
References: <20050515.152441.106262257.davem@davemloft.net>
	<20050515232020.GA19859@gondor.apana.org.au>
	<20050515235913.GA20242@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050515235913.GA20242@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 May 2005 09:59:13 +1000

> Please let me know if you still have any questions/problems with my
> patch.

No objections, I see what you are doing now.

It is basically the inverse of the case where
we hold the frag truesizes in the head SKB.

Once we rip apart the fraglist, we have to
repropagate the truesize and sock ownership
down from the head SKB to the frags.

I'll apply your patch, and Evgeniy's too.

Thanks.
