From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Get rid of NETIF_F_INTERNAL_STATS
Date: Sat, 28 Apr 2007 21:04:24 -0700 (PDT)
Message-ID: <20070428.210424.98555920.davem@davemloft.net>
References: <20070411122317.GA21159@gondor.apana.org.au>
	<1177739161.30071.165.camel@localhost.localdomain>
	<20070428055246.GA6172@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org, jgarzik@pobox.com,
	buytenh@gnu.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754560AbXD2EEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 00:04:14 -0400
In-Reply-To: <20070428055246.GA6172@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 28 Apr 2007 15:52:46 +1000

> > ==
> > Remove NETIF_F_INTERNAL_STATS: default to internal stats.
> > 
> > Herbert Xu conviced me that a new flag was overkill; every driver
> > currently overrides get_stats, so we might as well make the internal
> > one the default.  If someone did fail to set get_stats, they would now
> > get all 0 stats instead of "No statistics available".
> > 
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Looks good to me.

Applied, thanks everyone.
