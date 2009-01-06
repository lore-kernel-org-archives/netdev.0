From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ehea: use consistant type
Date: Tue, 06 Jan 2009 10:47:24 -0800 (PST)
Message-ID: <20090106.104724.60763449.davem@davemloft.net>
References: <20090106110511.43b0a87a.sfr@canb.auug.org.au>
	<20090105.161926.141190504.davem@davemloft.net>
	<20090106163454.b9f93b08.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tklein@de.ibm.com, themann@de.ibm.com, linuxppc-dev@ozlabs.org,
	raisch@de.ibm.com, netdev@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754110AbZAFSrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:47:23 -0500
In-Reply-To: <20090106163454.b9f93b08.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 6 Jan 2009 16:34:54 +1100

> ehea_plpar_hcall9() takes an "unsigned long" array to return its results,
> so change the arrays we pass to it to match.  This is currently only
> 64 bit code, so the transformation is actually a noop, but because
> ehea_plpar_hcall9() copies the values of registers into the array,
> if this was ported to a 32 bit hypervisor interface "unsigned long"
> would probably still be the correct type.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied.
