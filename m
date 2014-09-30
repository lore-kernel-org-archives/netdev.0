From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/3] bridge: Add vlan filtering support for
 default pvid
Date: Tue, 30 Sep 2014 17:07:18 -0400 (EDT)
Message-ID: <20140930.170718.1417042696038383945.davem@davemloft.net>
References: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, toshiaki.makita1@gmail.com,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaI3VHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 17:07:20 -0400
In-Reply-To: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Tue, 30 Sep 2014 15:30:59 -0400

> Version 2 of the series to introduce the default pvid support to
> vlan filtering in the bridge.  VLAN 1 (as recommended by 802.1q spec)
> is used as default pvid on ports. 
> The the user can over-ride this configuration by configuring their
> own vlan information. 
> The user can additionally change the default value throught the
> sysfs interface (netlink comming shortly).
> The user can turn off default pvid functionality by setting default
> pvid to 0. 
> This series changes the default behavior of the bridge when
> vlan filtering is turned on.  Currently, ports without any vlan
> filtering configured will not recevie any traffic at all.  This patch
> changes the behavior of the above ports to receive only untagged traffic.
> 
> Since v2:
> - Add ability to turn off default_pvid settings.
> - Drop the automiatic filtering support based on configured vlan devices (will
>   be its own series)

Looks like a new feature to me, thus why is this being targetted at 'net'
instead of 'net-next'?
