From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in IPv6 multicast.
Date: Tue, 27 Sep 2011 15:34:04 -0400 (EDT)
Message-ID: <20110927.153404.420686663860879218.davem@davemloft.net>
References: <1316819461-3192-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56185 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab1I0TeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 15:34:07 -0400
In-Reply-To: <1316819461-3192-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: greearb@candelatech.com
Date: Fri, 23 Sep 2011 16:11:01 -0700

> From: Ben Greear <greearb@candelatech.com>
> 
> If reg_vif_xmit cannot find a routing entry, be sure to
> free the skb before returning the error.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>

Applied.
