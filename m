From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2/2] [IPSEC] Move xfrm[46]_tunnel_check_size into
 xfrm[46]_output.c
Date: Mon, 2 Aug 2004 17:11:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802171126.09dc4887.davem@redhat.com>
References: <20040802093153.GA19706@gondor.apana.org.au>
	<20040802093500.GA19747@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040802093500.GA19747@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Aug 2004 19:35:00 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch moves xfrm[46]_tunnel_check_size() into xfrm[46]_output.c
> where it can be made static since it's only used there.
> 
> While moving the icmp.h inclusions over I also discovered that the
> tunnel files are missing an inclusion of net/protocol.h.  So I've
> added them as well.

The net/xfrm.h hunk failed, but I fixed that up by hand.

Applied, thanks.
