From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tg3: Fix tx race condition
Date: Mon, 07 Aug 2006 21:46:36 -0700 (PDT)
Message-ID: <20060807.214636.40574858.davem@davemloft.net>
References: <1155010214.5328.27.camel@rh4>
	<20060807.212135.77057626.davem@davemloft.net>
	<20060808042336.GA14039@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41859
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932485AbWHHEqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Aug 2006 00:46:34 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060808042336.GA14039@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 8 Aug 2006 14:23:36 +1000

> On Mon, Aug 07, 2006 at 09:21:35PM -0700, David Miller wrote:
> > From: "Michael Chan" <mchan@broadcom.com>
> > Date: Mon, 07 Aug 2006 21:10:14 -0700
> > 
> > > Fix a subtle race condition between tg3_start_xmit() and tg3_tx()
> > > discovered by Herbert Xu <herbert@gondor.apana.org.au>:
> > 
> > This one looks good to me.  Herbert please ACK this if you agree.
> 
> Yes the patch looks good to me too.

Applied, thanks everyone.
