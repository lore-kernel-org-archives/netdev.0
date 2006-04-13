From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip timer race
Date: Fri, 14 Apr 2006 03:31:30 +1000
Message-ID: <20060413173130.GA27158@gondor.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain> <E1FTjlM-00050V-00@gondolin.me.apana.org.au> <20060412124533.14e0c4ff@localhost.localdomain> <20060412200015.GA19878@gondor.apana.org.au> <20060412131527.71f42d58@localhost.localdomain> <20060412202551.GA20085@gondor.apana.org.au> <20060412145254.4dd21be6@localhost.localdomain> <20060412154214.1dd4117d@localhost.localdomain> <20060413124534.GA25333@gondor.apana.org.au> <20060413102630.7748f7b3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7178 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932334AbWDMRb4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 13:31:56 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060413102630.7748f7b3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 13, 2006 at 10:26:30AM -0700, Stephen Hemminger wrote:
> 
> Arp and neighbor table have the same rescheduling bug.

You're absolutely right.  Maybe the easy way out for now is to make
clip unremovable.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
