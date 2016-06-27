From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix resetting network_header in
 neigh_resolve_output and neigh_connected_output
Date: Mon, 27 Jun 2016 10:10:32 -0400 (EDT)
Message-ID: <20160627.101032.719251971537230839.davem@davemloft.net>
References: <1557d0eb9b5.10e107ce3332041.1418466288700186568@abahmed.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ab@abahmed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbcF0OLB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 10:11:01 -0400
In-Reply-To: <1557d0eb9b5.10e107ce3332041.1418466288700186568@abahmed.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Abdelrhman Ahmed <ab@abahmed.com>
Date: Thu, 23 Jun 2016 13:39:24 +0200

> neigh_resolve_output and neigh_connected_output resets the skb to network_header because of the retry loop and this reset will pull down the data pointer to the network header in the first iteration then hardware header will be added, but it will overwrite any data which is inserted between network header and hardware header (for example by netfilter hooks) only for the first packet(s) before using cached hardware header as neigh_hh_output (which is called for using cached hardware header) does not reset to the network header.

Please format your text properly into ~80 character long lines.
