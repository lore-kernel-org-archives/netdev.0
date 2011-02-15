From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arp_notify: unconditionally send gratuitous ARP for
 NETDEV_NOTIFY_PEERS.
Date: Mon, 14 Feb 2011 17:46:54 -0800 (PST)
Message-ID: <20110214.174654.115944453.davem@davemloft.net>
References: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ian.campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751408Ab1BOBqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 20:46:18 -0500
In-Reply-To: <1297446256-23917-1-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 11 Feb 2011 17:44:16 +0000

> NETDEV_NOTIFY_PEER is an explicit request by the driver to send a link
> notification while NETDEV_UP/NETDEV_CHANGEADDR generate link
> notifications as a sort of side effect.
> 
> In the later cases the sysctl option is present because link
> notification events can have undesired effects e.g. if the link is
> flapping. I don't think this applies in the case of an explicit
> request from a driver.
> 
> This patch makes NETDEV_NOTIFY_PEER unconditional, if preferred we
> could add a new sysctl for this case which defaults to on.
> 
> This change causes Xen post-migration ARP notifications (which cause
> switches to relearn their MAC tables etc) to be sent by default.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Ok, applied, thanks.
