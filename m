From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] Fixes for tunnel checksum and segmentation
 offloads
Date: Tue, 03 May 2016 16:01:12 -0400 (EDT)
Message-ID: <20160503.160112.1031115018727596649.davem@davemloft.net>
References: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756008AbcECUBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 16:01:15 -0400
In-Reply-To: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Mon, 02 May 2016 09:25:04 -0700

> This patch series is a subset of patches I had submitted for net-next.  I
> plan to drop these two patches from the v3 of "Fix Tunnel features and
> enable GSO partial for several drivers" and I am instead submitting them
> for net since these are truly fixes and likely will need to be backported
> to stable branches.
> 
> This series addresses 2 specific issues.  The first is that we could
> request TSO on a v4 inner header while not supporting checksum offload of
> the outer IPv6 header.  The second is that we could request an IPv6 inner
> checksum offload without validating that we could actually support an inner
> IPv6 checksum offload.

Series applied, thanks.
