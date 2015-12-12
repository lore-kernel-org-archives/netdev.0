From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/4] geneve: Add geneve udp port offload for
 ethernet devices
Date: Fri, 11 Dec 2015 19:58:40 -0500 (EST)
Message-ID: <20151211.195840.840105770291447529.davem@davemloft.net>
References: <1449598334-97674-1-git-send-email-anjali.singhai@intel.com>
	<1449598334-97674-2-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.org,
	kiran.patil@intel.com
To: anjali.singhai@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643AbbLLA6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 19:58:42 -0500
In-Reply-To: <1449598334-97674-2-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>
Date: Tue,  8 Dec 2015 10:12:11 -0800

> @@ -1013,6 +1013,20 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *	a new port starts listening. The operation is protected by the
>   *	vxlan_net->sock_lock.
>   *
> + * void (*ndo_add_geneve_port)(struct net_device *dev,
> + *			      sa_family_t sa_family, __be16 port);
> + *	Called by geneve to notiy a driver about the UDP port and socket

"notify"
