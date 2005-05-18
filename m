From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 02:47:33 +0200
Message-ID: <20050518004733.GG13748@postel.suug.ch>
References: <20050517.104947.112621738.davem@davemloft.net> <E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, akepner@sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1DYAHF-0006qW-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <E1DYAHF-0006qW-00@gondolin.me.apana.org.au> 2005-05-18 08:11
> Instead of measuring the distance using time, let's measure it
> in terms of packet counts.  So every time we receive a fragmented
> packet, we find all waiting fragments with the same src/dst pair.
> If the id is identical we perform reassembly, if it isn't we increase
> a counter in that fragment.  If the counter exceeds a threshold,
> we drop the fragment.

I like this, although the problem is derived to the definition
of the threshold. Any ideas on how to define this? A
combination of your idea together with the idea I stated in
another post which would additional expire fragments earlier
depending on the actual packet (or fragment) rate might give
better results.
