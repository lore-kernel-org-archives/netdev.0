From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] fix long-standing bug in 2.6/2.4
 skb_copy/skb_copy_expand
Date: Wed, 11 May 2005 13:56:45 -0700 (PDT)
Message-ID: <20050511.135645.124868850.davem@davemloft.net>
References: <20050508143259.GA30676@shaftnet.org>
	<E1DUyZO-0004Fp-00@gondolin.me.apana.org.au>
	<20050511203845.GA10770@shaftnet.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pizza@shaftnet.org
In-Reply-To: <20050511203845.GA10770@shaftnet.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Stuffed Crust <pizza@shaftnet.org>
Subject: Re: [PATCH] fix long-standing bug in 2.6/2.4 skb_copy/skb_copy_expand
Date: Wed, 11 May 2005 16:38:45 -0400

> As I said in my original message, it was a crude hack which has since
> been relegated to the great bitbucket of the sky.  All that's left is
> that "bugfix" patch.

If alloc_skb() does not do an skb_reserve(), then the bug fix
patch is unnecessary.  The "bug" only exists if you happen to
change alloc_skb() to do an skb_reserve().
