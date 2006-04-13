From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Thu, 13 Apr 2006 22:28:09 +1000
Message-ID: <20060413122809.GA25168@gondor.apana.org.au>
References: <20060412105545.3b089dd8@localhost.localdomain> <E1FTjlM-00050V-00@gondolin.me.apana.org.au> <20060412124533.14e0c4ff@localhost.localdomain> <20060412200015.GA19878@gondor.apana.org.au> <20060412131527.71f42d58@localhost.localdomain> <20060412202551.GA20085@gondor.apana.org.au> <20060412145254.4dd21be6@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, chas@cmf.nrl.navy.mil,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16402 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964901AbWDMM2d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:28:33 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060412145254.4dd21be6@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 12, 2006 at 02:52:54PM -0700, Stephen Hemminger wrote:
> If Classical IP over ATM module is loaded, its neighbor table gets
> populated when permanent neighbor entries are created; but these entries
> are not flushed when the device is removed. Since the entry never gets
> flushed the unregister of the network device never completes.
> 
> This version of the patch also adds locking around the reference to
> the atm arp daemon to avoid races with events and daemon state changes.
> (Note: barrier() was never really safe)
> 
> Bug-reference: http://bugzilla.kernel.org/show_bug.cgi?id=6295
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Thanks a lot Stephen.  This version looks good.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
