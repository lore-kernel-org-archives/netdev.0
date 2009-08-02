From: David Miller <davem@davemloft.net>
Subject: Re: netpoll + xmit_lock == deadlock
Date: Sun, 02 Aug 2009 13:07:04 -0700 (PDT)
Message-ID: <20090802.130704.133993421.davem@davemloft.net>
References: <20090729073523.GA4515@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, netdev@vger.kernel.org, mcarlson@broadcom.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50956
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753247AbZHBUG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 16:06:56 -0400
In-Reply-To: <20090729073523.GA4515@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 29 Jul 2009 15:35:23 +0800

> So if a driver is in the TX path, and a printk occurs, then a
> recursive dead lock can occur if that driver tries to take the
> xmit lock in its poll function to clean up descriptors.

My position has always been that such printk's are simply
not allowed.  (check archives if you don't believe me :-)

The locking is going to get rediculious if we start having
to account for this.
