From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Thu, 13 Jan 2005 19:44:51 -0800
Message-ID: <20050113194451.1b6685a2.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<Pine.LNX.4.58.0501131741430.25252@w-sridhar.beaverton.ibm.com>
	<20050114021005.GA11962@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114021005.GA11962@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Jan 2005 13:10:05 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Since there is no reclaim for sk_wmem_queued it doesn't happen
> there.
> 
> So taking out the adjustments should not cause any problems of
> sk_wmem_queued, theoretically :)

If we take out the skb->truesize adjustment, as the test patch does,
then we must take out the sk_wmem_queued and sk_forward_alloc
adjustments, as the test patch also does. :-)
