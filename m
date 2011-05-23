From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Fix multicast registration on semi-promiscuous
 mode
Date: Mon, 23 May 2011 16:34:23 -0400 (EDT)
Message-ID: <20110523.163423.238991063346962299.davem@davemloft.net>
References: <20110520.162801.1310159491178676084.davem@davemloft.net>
	<1306157795-13377-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052Ab1EWUeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 16:34:36 -0400
In-Reply-To: <1306157795-13377-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Mon, 23 May 2011 10:36:35 -0300

> Ehea will not register multicast groups in phyp if the physical
> interface is in promiscuous mode. But it should register if the
> logical port is in promiscuous mode, but the physical port is not.
> 
> Ehea physical promiscuous mode is defined by ehea_port->promisc,
> while logical port is defined by IFF_PROMISC.
> 
> So currently, if the user set the interface in promiscuous mode,
> IGMP will not be registred in PHYP, and PHYP will never pass
> the multicast packet to the logical port, which is bad
> 
> So, this patch just fixes it, assuring that we register in phyp
> if the physical port is not on promiscuous mode.
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied, thanks.
