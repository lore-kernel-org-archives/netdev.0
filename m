From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [10/*] [TCP] Get rid of dst_ptmu/ext2_header_len
Date: Mon, 7 Mar 2005 09:33:12 -0800
Message-ID: <20050307093312.68a2dd22.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050216103744.GA476@gondor.apana.org.au>
	<20050307114533.GA11190@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050307114533.GA11190@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Mar 2005 22:45:33 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is a patch that replaces all occurrences of dst_pmtu in the TCP
> stack.  As a result we no longer need ext2_header_len.
> 
> This has a nice synergetic effect with Arnaldo's latest change to
> linux/tcp.h :)
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> I'll be removing other users of dst->path/dst_pmtu next.

Also applied, thanks Herbert.
