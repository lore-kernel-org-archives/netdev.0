From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [1/1] xfrm: skb_cow_data() does not set proper owner for new
 skbs.
Date: Sun, 15 May 2005 15:18:46 -0700 (PDT)
Message-ID: <20050515.151846.85410444.davem@davemloft.net>
References: <20050514134834.GA2698@uganda.factory.vocord.ru>
	<E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DXE3h-0002jR-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/1] xfrm: skb_cow_data() does not set proper owner for new skbs.
Date: Sun, 15 May 2005 18:01:09 +1000

> IPv4's ip_push_pending_frames attributes all the data to the first
> skb which breaks when the packet is sent through ip_fragment since
> the latter does not undo the truesize attribution.

I'm %99 sure this one is on purpose.  I'll have to dig into
the archives and source repo history to get the details
though.
