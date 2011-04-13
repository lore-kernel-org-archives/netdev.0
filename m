From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/2] net: Disable all TSO features when SG is
 disabled
Date: Tue, 12 Apr 2011 19:29:55 -0700 (PDT)
Message-ID: <20110412.192955.71101280.davem@davemloft.net>
References: <1302655117.2880.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751794Ab1DMCaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 22:30:30 -0400
In-Reply-To: <1302655117.2880.33.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Apr 2011 01:38:37 +0100

> The feature flags NETIF_F_TSO and NETIF_F_TSO6 independently enable
> TSO for IPv4 and IPv6 respectively.  However, the test in
> netdev_fix_features() and its predecessor functions was never updated
> to check for NETIF_F_TSO6, possibly because it was originally proposed
> that TSO for IPv6 would be dependent on both feature flags.
> 
> Now that these feature flags can be changed independently from
> user-space and we depend on netdev_fix_features() to fix invalid
> feature combinations, it's important to disable them both if
> scatter-gather is disabled.  Also disable NETIF_F_TSO_ECN so
> user-space sees all TSO features as disabled.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
