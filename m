From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:13:52 -0700 (PDT)
Message-ID: <20050517.151352.41634495.davem@davemloft.net>
References: <20050517.104947.112621738.davem@davemloft.net>
	<E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 18 May 2005 08:11:01 +1000

> Instead of measuring the distance using time, let's measure it
> in terms of packet counts.  So every time we receive a fragmented
> packet, we find all waiting fragments with the same src/dst pair.
> If the id is identical we perform reassembly, if it isn't we increase
> a counter in that fragment.  If the counter exceeds a threshold,
> we drop the fragment.

And you protect against purposefully built malicious fragments how?
