From: "David S. Miller" <davem@redhat.com>
Subject: Re: patches
Date: Thu, 29 Jul 2004 19:20:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040729192046.0a3fb71d.davem@redhat.com>
References: <20040729181948.5d36f47f.davem@redhat.com>
	<20040730012431.GA21253@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040730012431.GA21253@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004 11:24:31 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Here is the routing headers patch again.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

Based upon reading of the rest of the thread about
this patch I understand that:

1) Direction checking suggested by Yoshifuji is unecessary
   because on input segments_left will be zero in the type 0
   routing header.

2) Both ipv4 and ipv6 erroneously do the xfrm route lookup
   using the first hop destination not the final destination.
   And this needs to be fixed with a followon patch.

Is this correct?
