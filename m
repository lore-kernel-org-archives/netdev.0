From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV4] Check mtu instead of frag_list in ip_push_pending_frames
Date: Wed, 23 Mar 2005 12:20:02 -0800
Message-ID: <20050323122002.04fc046e.davem@davemloft.net>
References: <20050321105622.GA23809@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050321105622.GA23809@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 21:56:22 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The fix is similar to what we did in ip_output.  Instead of checking
> whether frag_list is empty, we check the condition skb->len <= dst_mtu
> directly and set the DF bit based on that.

Looks good, applied.

Thanks Herbert.
