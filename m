From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: Allow to create links with given ifindex
Date: Thu, 02 Aug 2012 16:26:01 -0700 (PDT)
Message-ID: <20120802.162601.2080519313891137444.davem@davemloft.net>
References: <50179F66.1000604@parallels.com>
	<878ve0dtw3.fsf@xmission.com>
	<1343903310.9299.184.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, xemul@parallels.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59732 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab2HBX0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Aug 2012 19:26:02 -0400
In-Reply-To: <1343903310.9299.184.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Aug 2012 12:28:30 +0200

> Strange because I see no false sharing on this ifindex location for
> loopback device.

Are you sure netdev->rx_dropped isn't being incremented?  That appears
as if it would land on the same cache line as netdev->ifindex.
