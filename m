From: "David S. Miller" <davem@redhat.com>
Subject: Re: [AH6] Disallow mutable bits after AH header
Date: Wed, 28 Jul 2004 09:11:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728091148.63defec2.davem@redhat.com>
References: <20040723135320.GA26000@gondor.apana.org.au>
	<20040723133737.447a9598.davem@redhat.com>
	<20040728114632.GA7103@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040728114632.GA7103@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jul 2004 21:46:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> In that patch I removed the nh_offset parameter to ipv6_clear_mutable_options.
> That broke ah6_input() because it relies on that variable to set the nexthdr.
> 
> The following patch fixes this by moving this work out to the caller
> xfrm6_rcv() where the information is already available.  It also removes
> an unnecessary call to ip6_find_1stfragopt() in xfrm6_rcv() since nhoffp
> already points to the nexthdr preceding the current header.

Applied, thanks.
