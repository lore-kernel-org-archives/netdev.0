From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport
 mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Mon, 31 Jan 2005 11:40:04 -0800
Message-ID: <20050131114004.6c61cdc1.davem@davemloft.net>
References: <20050130224404.5f78d28a.akpm@osdl.org>
	<E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, au@unterluggauer.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CvZCT-00017g-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 21:54:33 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Well without the check we would have silently ignored the sequence
> number which is why you wouldn't have noticed the problem with racoon
> before.
> 
> However, for those who need to use the sequence number this check is
> necessary.

Yes, but the loop in the kernel must be prevented nevertheless,
buggy userland or not.
