From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] smsc95xx: Use skb_cow_head to deal with cloned skbs
Date: Thu, 20 Apr 2017 16:28:59 -0400 (EDT)
Message-ID: <20170420.162859.2258254560926857767.davem@davemloft.net>
References: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        UNGLinuxDriver@microchip.com
To: james.hughes@raspberrypi.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943098AbdDTU3G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:29:06 -0400
In-Reply-To: <20170419101340.27929-1-james.hughes@raspberrypi.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Hughes <james.hughes@raspberrypi.org>
Date: Wed, 19 Apr 2017 11:13:40 +0100

> The driver was failing to check that the SKB wasn't cloned
> before adding checksum data.
> Replace existing handling to extend/copy the header buffer
> with skb_cow_head.
> 
> Signed-off-by: James Hughes <james.hughes@raspberrypi.org>

Applied.
