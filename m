From: "David S. Miller" <davem@redhat.com>
Subject: Re: [AH4] Save daddr iff options are present
Date: Sat, 24 Jul 2004 22:35:11 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724223511.49847caa.davem@redhat.com>
References: <20040724014415.GA5866@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040724014415.GA5866@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 24 Jul 2004 11:44:15 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This is a little optimisation for AH4.  When I moved the tunnel code out,
> I put the daddr copying code on the main path which is unnecessary since
> daddr is only mutable if IP options are present.
> 
> This patch moves the saving and restoring of daddr under the check for
> the existence of IP options.

Looks good to me, applied.

Thanks Herbert.
