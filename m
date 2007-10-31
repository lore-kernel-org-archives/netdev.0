From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 17:06:32 +1100
Message-ID: <200710311706.33142.rusty@rustcorp.com.au>
References: <20071030.204002.193703502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jens.axboe@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38268 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751943AbXJaGGb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 02:06:31 -0400
In-Reply-To: <20071030.204002.193703502.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 31 October 2007 14:40:02 David Miller wrote:
> I just checked the following bug fix into net-2.6
>
> Rusty, have a quick look at virtio_net wrt. the changes I
> made to skb_to_sgvec()'s behavior.  I think I might have
> even fixed something :-)

Grr, the scatterlist changes are really pissing me off.  We get ugly tricky 
code *and* transition pain.

I hate to suggest this, but I don't supposed there's a chance we can revert it 
for 2.6.24 and do something cleaner for 2.6.25?

Rusty.
