From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: use consistent types
Date: Tue, 06 Jan 2009 10:47:53 -0800 (PST)
Message-ID: <20090106.104753.91462944.davem@davemloft.net>
References: <20081231140225.48b695ef.sfr@canb.auug.org.au>
	<20090106163908.2e6134f4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, santil@us.ibm.com,
	benh@kernel.crashing.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36376
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751200AbZAFSrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:47:51 -0500
In-Reply-To: <20090106163908.2e6134f4.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 6 Jan 2009 16:39:08 +1100

> These variables are only used with an interface that just dumps their
> values into registers to be passed to the hypervisor. The arguments
> to that interface are declared to be "unsigned long", so make these
> variables match.  The macros are only used with these variables, so make
> them match as well.
> 
> This code is currently only built for 64bit powerpc, so the transformation
> is really a noop.  If the interface was ever ported to 32 bit, it would
> almost certainly still use registers to pass the parameters and so
> "unsigned long" would still be appropriate.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Also applied, thanks Stephen.
