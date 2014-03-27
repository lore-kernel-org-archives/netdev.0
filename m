From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] vlan: Mask off vlan acceleration features on
 vlan device.
Date: Thu, 27 Mar 2014 15:12:05 -0400 (EDT)
Message-ID: <20140327.151205.1227455812702138170.davem@davemloft.net>
References: <1395865521-2318-1-git-send-email-vyasevic@redhat.com>
	<1395865711-3347-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56804 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251AbaC0TMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 15:12:07 -0400
In-Reply-To: <1395865711-3347-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Wed, 26 Mar 2014 16:28:31 -0400

> Some drivers incorrectly assign vlan acceleration features to
> vlan_features thus causing issues for Q-in-Q vlan configurations.
> Prevent this once and for all by masking off acceleration features
> for vlan devices until such time as we support stacked acceleration.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Vlad, I've thought more about this, I'd rather we emit a warning so
we can fix the drivers.

If they are setting the flags wrong, we probably want to go take a
look to see if they are doing anything else related wrong too.
