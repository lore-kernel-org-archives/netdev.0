From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ehea: use consistent type
Date: Tue, 30 Dec 2008 21:51:01 -0800 (PST)
Message-ID: <20081230.215101.228854586.davem@davemloft.net>
References: <20081231141730.81449124.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, raisch@de.ibm.com,
	themann@de.ibm.com, tklein@de.ibm.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51274
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751152AbYLaFu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 00:50:58 -0500
In-Reply-To: <20081231141730.81449124.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 Dec 2008 14:17:30 +1100

> ehea_plpar_hcall9() takes an unsigned long array, so pass that.
> 
> This change will avoid some warnings when we change u64 to unsigned
> long long.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Patch rejected, for the same reasons as the other driver
change.

We're not going to poop up some drivers with the assumption that long
is 64-bit.

Thanks ;-)
