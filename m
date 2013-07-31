From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v6 0/4] export device physical port id to
 userspace
Date: Tue, 30 Jul 2013 17:36:03 -0700 (PDT)
Message-ID: <20130730.173603.2133735333775668182.davem@davemloft.net>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Narendra_K@Dell.com, bhutchings@solarflare.com,
	john.r.fastabend@intel.com, or.gerlitz@gmail.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43969 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758632Ab3GaAgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 20:36:07 -0400
In-Reply-To: <1375114612-537-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 29 Jul 2013 18:16:48 +0200

> Jiri Pirko (4):
>   net: add ndo to get id of physical port of the device
>   rtnl: export physical port id via RT netlink
>   net: export physical port id via sysfs
>   igb/igbvf: implement ndo_get_phys_port_id

I applied all of the infrastructure patches (#1, #2, and #3) to net-next.

I'll let Jeff Kirsher pick up the Intel driver bits.
