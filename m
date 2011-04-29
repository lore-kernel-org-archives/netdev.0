From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4,ipv6,bonding: Restore control over
 number of peer notifications
Date: Fri, 29 Apr 2011 12:44:29 -0700 (PDT)
Message-ID: <20110429.124429.15250719.davem@davemloft.net>
References: <1303867552.2850.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, kaber@trash.net,
	netdev@vger.kernel.org, brian.haley@hp.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37450
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760869Ab1D2TpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 15:45:02 -0400
In-Reply-To: <1303867552.2850.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 27 Apr 2011 02:25:52 +0100

> For backward compatibility, we should retain the module parameters and
> sysfs attributes to control the number of peer notifications
> (gratuitous ARPs and unsolicited NAs) sent after bonding failover.
> Also, it is possible for failover to take place even though the new
> active slave does not have link up, and in that case the peer
> notification should be deferred until it does.
> 
> Change ipv4 and ipv6 so they do not automatically send peer
> notifications on bonding failover.
> 
> Change the bonding driver to send separate NETDEV_NOTIFY_PEERS
> notifications when the link is up, as many times as requested.  Since
> it does not directly control which protocols send notifications, make
> num_grat_arp and num_unsol_na aliases for a single parameter.  Bump
> the bonding version number and update its documentation.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
