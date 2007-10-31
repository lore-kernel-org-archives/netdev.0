From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 00:43:20 -0700 (PDT)
Message-ID: <20071031.004320.175325164.davem@davemloft.net>
References: <20071030.204002.193703502.davem@davemloft.net>
	<20071031073207.GA5059@kernel.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: jens.axboe@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752921AbXJaHnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 03:43:20 -0400
In-Reply-To: <20071031073207.GA5059@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 31 Oct 2007 08:32:07 +0100

> [SG] Remove __sg_mark_end()
> 
> Make sg_mark_end() NOT overwrite the page link. Then it can be used
> after filling the sg table, which is what users want. That means that
> __sg_mark_end() is no longer useful, so kill it.
> 
> It's important the sg entries be initialized before using sg_mark_end(),
> so also add a debug check to catch use-before-init.
> 
> Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

Ok, but I just pushed my changes to Linus and once those show up
you'll need to extend this patch to kill the '__' prefix from
all the rest of the calls which will be in the tree.

Thanks!
