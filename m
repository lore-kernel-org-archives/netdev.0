From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 3/3] be2net: fix initialization of
 vlan_prio_bmap
Date: Mon, 27 Jun 2011 00:07:53 -0700 (PDT)
Message-ID: <20110627.000753.1871339000879623740.davem@davemloft.net>
References: <9126f0fa-e344-4bf8-afe2-270985b37d75@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757037Ab1F0HH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 03:07:57 -0400
In-Reply-To: <9126f0fa-e344-4bf8-afe2-270985b37d75@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Mon, 27 Jun 2011 12:11:53 +0530

> Initialization of this field to "all priorities" must be done before MCC queue
> creation. As soon as the MCC queue is created, an event modifying this value
> may be received.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
