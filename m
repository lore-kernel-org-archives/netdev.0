From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 0/3] export device physical port id to
 userspace
Date: Wed, 24 Jul 2013 16:00:37 -0700 (PDT)
Message-ID: <20130724.160037.37317394789474047.davem@davemloft.net>
References: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752775Ab3GXXAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 19:00:38 -0400
In-Reply-To: <1374498317-6442-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 22 Jul 2013 15:05:14 +0200

> This patchset is based on patch by Narendra_K@Dell.com
> Once device which can change phys port id during its lifetime adopts this,
> NETDEV_CHANGEPHYSPORTID event will be added and driver will call
> call_netdevice_notifiers(NETDEV_NETDEV_CHANGEPHYSPORTID, dev) to propagate
> the change to userspace.
> 
> v1->v2: as suggested by Ben, handle -EOPNOTSUPP in rtnl code (wrapped up ndo call)
> v2->v3: adjusted patch 1 commit message

As mentioned we'd like to have at least one driver implementing the new
interface as part of the patch set.

Once you have that sorted I think this is mostly ready.
