From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/16] mlxsw: Implement IPV4 unicast routing
Date: Tue, 05 Jul 2016 09:10:43 -0700 (PDT)
Message-ID: <20160705.091043.970062018694402093.davem@davemloft.net>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37636 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbcGEQKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 12:10:47 -0400
In-Reply-To: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  5 Jul 2016 11:27:36 +0200

> This patchset enables IPv4 unicast routing in the Mellanox Spectrum ASIC
> switch driver. This builds upon the work that was done by a couple of
> previous patchsets.
> 
> Patches 1,2,6 add a couple of dependencies outside the driver. Namely, the
> ability to propagate ndo_neigh_construct()/destroy() through stacked devices and
> a notification whenever DELAY_PROBE_TIME changes. When propagated down, the
> ndos allow drivers to add and remove neighbour entries from their private
> neighbour table. The DELAY_PROBE_TIME notification gives drivers the ability to
> correctly configure their polling interval for neighbour activity, so that
> active neighbour won't be marked as STALE.
> 
> Patches 3-5,7-8 add the neighbour offloading infrastructure, where patch 7 uses
> the DELAY_PROBE_TIME notification in order to correctly configure the device's
> polling interval. Patch 8 finally programs neighbours to the device's table
> based on NEIGH_UPDATE notifications, so that directly connected routes can
> be used.
> 
> Patches 9-16 build upon the previous patches and extend the router with
> remote routes (nexthop) support.

Looks good to me, series applied, thanks Jiri!
