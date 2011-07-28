From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] vlan:remove duplicate <linux/if_vlan.h>
Date: Thu, 28 Jul 2011 01:38:30 -0700 (PDT)
Message-ID: <20110728.013830.1949919665209265585.davem@davemloft.net>
References: <cover.1311841820.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079Ab1G1Iif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 04:38:35 -0400
In-Reply-To: <cover.1311841820.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Thu, 28 Jul 2011 16:37:38 +0800

> As net/8021q/vlan.h already includes <linux/if_vlan.h>,
> so other files that includes vlan.h need not to include it.

Please do not do this.

If someone wants to remove this implicit header dependency,
that someone will need to add all of the includes back.

It is better for people to include all the headers they need,
rather than rely upon such indirect inclusions.

I am not applying these patches.

