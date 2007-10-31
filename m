From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 08:47:09 +0100
Message-ID: <20071031074708.GC5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net> <20071031073207.GA5059@kernel.dk> <20071031.004320.175325164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:26090 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbXJaHts (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 03:49:48 -0400
Content-Disposition: inline
In-Reply-To: <20071031.004320.175325164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31 2007, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Wed, 31 Oct 2007 08:32:07 +0100
> 
> > [SG] Remove __sg_mark_end()
> > 
> > Make sg_mark_end() NOT overwrite the page link. Then it can be used
> > after filling the sg table, which is what users want. That means that
> > __sg_mark_end() is no longer useful, so kill it.
> > 
> > It's important the sg entries be initialized before using sg_mark_end(),
> > so also add a debug check to catch use-before-init.
> > 
> > Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
> 
> Ok, but I just pushed my changes to Linus and once those show up
> you'll need to extend this patch to kill the '__' prefix from
> all the rest of the calls which will be in the tree.
> 
> Thanks!

No problem, I'll base further sg_mark_end() updates on top of yours.
Just need to get that last email I sent out resolved, the
gss_krb5_crypto bits.

-- 
Jens Axboe

