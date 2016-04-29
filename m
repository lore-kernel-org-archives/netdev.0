From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: fix initialization with custom link
 parameters
Date: Fri, 29 Apr 2016 15:09:40 -0400 (EDT)
Message-ID: <20160429.150940.319238424947983936.davem@davemloft.net>
References: <7c19200582d6f4272cee914934f428775e405e89.1461854177.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750875AbcD2TJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 15:09:44 -0400
In-Reply-To: <7c19200582d6f4272cee914934f428775e405e89.1461854177.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Thu, 28 Apr 2016 16:36:30 +0200

> Commit 0c867c9bf84c ("vxlan: move Ethernet initialization to a separate
> function") changed initialization order and as an unintended result, when the
> user specifies additional link parameters (such as IFLA_ADDRESS) while
> creating vxlan interface, those are overwritten by vxlan_ether_setup later.
> 
> It's necessary to call ether_setup from withing the ->setup callback. That
> way, the correct parameters are set by rtnl_create_link later. This is done
> also for VXLAN-GPE, as we don't know the interface type yet at that point,
> and changed to the correct interface type later.
> 
> Fixes: 0c867c9bf84c ("vxlan: move Ethernet initialization to a separate function")
> Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied, thanks Jiri.
