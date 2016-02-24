From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 16:49:34 -0500 (EST)
Message-ID: <20160224.164934.1286780116750770665.davem@davemloft.net>
References: <20160224.114839.300751853393269073.davem@davemloft.net>
	<CALzJLG-CR1Ac5biwP5CuFbygqCOWh4-VGQc-XZ=BuZQLRnnRDg@mail.gmail.com>
	<CALzJLG8CiRRBqUziAFOXE2RAmEDUMgJK2GM6SF3mz_HueRfdvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, galp@mellanox.com,
	ogerlitz@mellanox.com, kaber@trash.net
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57370 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbcBXVtg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:49:36 -0500
In-Reply-To: <CALzJLG8CiRRBqUziAFOXE2RAmEDUMgJK2GM6SF3mz_HueRfdvQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Wed, 24 Feb 2016 22:35:16 +0200

> BTW we choose the first option since the "buggy" function is called
> "vlan_hw_filter_capable" which lead us to decide that the function
> should be looking for ->hw_features and not ->features.
> and i think this way it makes more sense.

Again, anything doing checks on ->hw_features other than for the
purposes of the validation of a ->feature change is a bug.
