From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/24] [IPSEC]: Merge common code into
 xfrm_bundle_create
Date: Tue, 13 Nov 2007 21:38:48 -0800 (PST)
Message-ID: <20071113.213848.135920298.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZz-0001HL-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45829
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757260AbXKNFit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:38:49 -0500
In-Reply-To: <E1IplZz-0001HL-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:27 +0800

> [IPSEC]: Merge common code into xfrm_bundle_create
> 
> Half of the code in xfrm4_bundle_create and xfrm6_bundle_create are common.
> This patch extracts that logic and puts it into xfrm_bundle_create.  The
> rest of it are then accessed through afinfo.
> 
> As a result this fixes the problem with inter-family transforms where we
> treat every xfrm dst in the bundle as if it belongs to the top family.
> 
> This patch also fixes a long-standing error-path bug where we may free the
> xfrm states twice.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
