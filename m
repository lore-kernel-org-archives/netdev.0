From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Make it possible to add vlan with id 4095
Date: Fri, 28 Sep 2012 13:44:17 -0400 (EDT)
Message-ID: <20120928.134417.1763308761361480629.davem@davemloft.net>
References: <20120928123258.9454.95197.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: paulius.zaleckas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab2I1RoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 13:44:19 -0400
In-Reply-To: <20120928123258.9454.95197.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Fri, 28 Sep 2012 15:32:58 +0300

> vconfig help tells that vlan_id should be 0-4095, but fails
> with 4095.
> 
> There is an off-by-one bug while evaluating vlan_id.
> Fix it by evaluating against count(4096), not mask(0x0fff = 4095).
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

Awesome, we don't need VXVLAN any more after this fix.
