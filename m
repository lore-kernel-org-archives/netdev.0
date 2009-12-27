From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 0/10] llc enhancements
Date: Sat, 26 Dec 2009 20:32:52 -0800 (PST)
Message-ID: <20091226.203252.02261992.davem@davemloft.net>
References: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acme@ghostprotocols.net,
	eric.dumazet@gmail.com
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58392
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750908AbZL0Ecu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Dec 2009 23:32:50 -0500
In-Reply-To: <1261864268-10460-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Sat, 26 Dec 2009 23:50:58 +0200

> 
> This patch set modifies the LLC code to scale the socket lookup code
> for a large number of interfaces and large number of sockets bound to
> the same SAP. We use it for STP traffic generation from a large number
> of virtual STP ports, via virtual network interfaces.
> 
> In the process we converted the socket lookup code and sap list to use
> RCU. It also contains some general cleanups (use dev_hard_header
> instead of handcrafting the headers) and enhancements (LLC_OPT_PKTINFO).

Looks good, applied to net-next-2.6, thanks!
