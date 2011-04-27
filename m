From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next-2.6] ipv4,ipv6,bonding: Restore control over
 number of peer notifications
Date: Tue, 26 Apr 2011 22:09:06 -0400
Message-ID: <4DB77AC2.5070207@hp.com>
References: <1303867552.2850.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:19364 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756447Ab1D0CJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 22:09:11 -0400
In-Reply-To: <1303867552.2850.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2011 09:25 PM, Ben Hutchings wrote:
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

Signed-off-by: Brian Haley <brian.haley@hp.com>
