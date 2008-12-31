From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ehea: bitops work on unsigned longs
Date: Tue, 30 Dec 2008 21:51:56 -0800 (PST)
Message-ID: <20081230.215156.151347026.davem@davemloft.net>
References: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751363AbYLaFvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 00:51:53 -0500
In-Reply-To: <20081231141853.c6d123c4.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 Dec 2008 14:18:53 +1100

> These changes will avoid several warnings when we change u64 to unsigned
> long long.
> 
> Also, ehea_driver_flags is only used in ehca_main.c
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---

And also rejected, just like the previous two.

This is so much worse than the problems we had with
printing u64's and it's being done as a result to
the "fix" for that.

Please let's not do this...
