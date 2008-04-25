From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] ibm_newemac: Increase MDIO timeouts
Date: Sat, 26 Apr 2008 08:22:38 +1000
Message-ID: <1209162158.5420.35.camel@pasglop>
References: <20080423051832.63BF7DDF65@ozlabs.org>
	 <20080425165703.864e63bd.billfink@mindspring.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	super.firetwister@googlemail.com
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38024 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933124AbYDYWXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 18:23:06 -0400
In-Reply-To: <20080425165703.864e63bd.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-04-25 at 16:57 -0400, Bill Fink wrote:
> On Wed, 23 Apr 2008, Benjamin Herrenschmidt wrote:
> 
> > This patch doubles the MDIO timeouts in EMAC as there are field
> > cases where they are two short to communicate with some PHYs.
> 
> I guess them being "two short" is why they needed to be doubled.  :-)

Well, in that case, it makes sense, it's still pretty short and better
safe than sorry. On day I may look at actually measuring PHYs and see if
it's worth trying to do sleeping waits in there.

Ben.


