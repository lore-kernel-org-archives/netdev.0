From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: initialize xfrm encap_oa
Date: Sun, 25 Jan 2009 20:49:21 -0800 (PST)
Message-ID: <20090125.204921.244150980.davem@davemloft.net>
References: <1232713828-6725-1-git-send-email-timo.teras@iki.fi>
	<20090123221137.GA806@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751296AbZAZEtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2009 23:49:19 -0500
In-Reply-To: <20090123221137.GA806@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 24 Jan 2009 09:11:38 +1100

> On Fri, Jan 23, 2009 at 02:30:28PM +0200, Timo Teras wrote:
> > Currently encap_oa is left uninitialized, so it contains garbage data which
> > is visible to userland via Netlink. Initialize it by zeroing it out.
> > 
> > Signed-off-by: Timo Teras <timo.teras@iki.fi>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
