From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 1/2] net: Utility function to get
 affinity_hint by policy
Date: Mon, 10 Mar 2014 16:04:08 -0400 (EDT)
Message-ID: <20140310.160408.1561130723524404573.davem@davemloft.net>
References: <1394350749-30522-1-git-send-email-amirv@mellanox.com>
	<1394350749-30522-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com, prarit@redhat.com, gvaradar@cisco.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbaCJUEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:04:10 -0400
In-Reply-To: <1394350749-30522-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun,  9 Mar 2014 09:39:08 +0200

> This function sets the affinity_mask according to a numa aware policy.
> affinity_mask could be used as an affinity hint for the IRQ related to
> this rx queue.
> Current policy is to spread rx queues accross cores - local cores first.
> It could be extended in the future.
> 
> CC: Prarit Bhargava <prarit@redhat.com>
> CC: Govindarajulu Varadarajan <gvaradar@cisco.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

I hate to delay this even more, but I think Ben is right, this is really
a generic function that probably belongs under kernel/  The block layer
folks to multiqueue things on some devices, and they therefore could find
it useful as well.
