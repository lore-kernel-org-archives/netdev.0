From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] mac802154: fix multiple WPAN handling
Date: Tue, 01 Apr 2014 16:26:15 -0400 (EDT)
Message-ID: <20140401.162615.527797088376105489.davem@davemloft.net>
References: <1396294666-14005-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaDAU0Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:26:16 -0400
In-Reply-To: <1396294666-14005-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Mon, 31 Mar 2014 21:37:44 +0200

> The current mac802154 stack allows an arbitrary number of WPAN netdevs for any
> given PHY, which is not sensible and not supported by all hardware with in-tree
> drivers. Also, previous commits have introduced configuration options that
> apply to WPAN devices, but were set to apply to the underlying PHY.
> 
> This patch set fixes both, allowing only one WPAN device to be up at any given
> time, and making WPAN-related settings per-WPAN instead of per-PHY.

Series applied.
