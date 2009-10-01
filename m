From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] ethtool: Add reset operation
Date: Thu, 01 Oct 2009 13:14:24 -0700 (PDT)
Message-ID: <20091001.131424.157091984.davem@davemloft.net>
References: <1254426195.2735.16.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47583
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756543AbZJAUOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 16:14:04 -0400
In-Reply-To: <1254426195.2735.16.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 01 Oct 2009 20:43:15 +0100

> After updating firmware stored in flash, users may wish to reset the
> relevant hardware and start the new firmware immediately.  This should
> not be completely automatic as it may be disruptive.
> 
> A selective reset may also be useful for debugging or diagnostics.
> 
> This adds a separate reset operation which takes flags indicating the
> components to be reset.  Drivers are allowed to reset only a subset of
> those requested, and must report the actual subset.  This allows the
> use of generic component masks and some future expansion.

This looks fine to me.
