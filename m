From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 23 Sep 2004 16:41:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923164149.5368d291.davem@davemloft.net>
References: <20040923161141.4ea9be4c.davem@davemloft.net>
	<E1CAdCy-0001FM-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CAdCy-0001FM-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 09:41:04 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> David S. Miller <davem@davemloft.net> wrote:
> > 
> > That means as the window fills up, we have to see 44 ACKs
> > before we are able to send the next TSO frame.  Needless to
> > say that breaks ACK clocking completely.
> 
> Hang on a second, the same problem would occur before the congestion
> changes were made, right?

Previously we counted TSO frames as single "packets" as long as
we could fit one more frame into the congestion window we'd spit
out the whole TSO frame, and this kept the pipe full.
