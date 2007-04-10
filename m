From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: [UPDATED] Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 02:28:08 +0200
Message-ID: <461ADA18.8010206@trash.net>
References: <20070410003243.32106.98266.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com, cramerj@intel.com,
	auke-jan.h.kok@intel.com, christopher.leech@intel.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47474 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344AbXDJA2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 20:28:30 -0400
In-Reply-To: <20070410003243.32106.98266.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter P Waskiewicz Jr wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> 
> Update: Fixed a typecast in free_netdev() for the egress_subqueue list.
> 
> Added an API and associated supporting routines for multiqueue network devices.
> This allows network devices supporting multiple TX queues to configure each
> queue within the netdevice and manage each queue independantly.  Changes to the
> PRIO Qdisc also allow a user to map multiple flows to individual TX queues,
> taking advantage of each queue on the device.


This indeed looks a lot better than the first patch. I'm too tired to
fully review this now, but could you please post the corresponding e1000
patch? From a quick look I'm guessing that this patch changes the
behaviour of the prio qdisc from strict priority to whatever scheduling
mechanism e1000 uses for its queues when the multiqueue config option
is enabled, which might surprise people.

