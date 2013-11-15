From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] macvlan: disable LRO on lowerdev instead of
 a macvlan
Date: Fri, 15 Nov 2013 17:56:37 -0500 (EST)
Message-ID: <20131115.175637.920595518200727670.davem@davemloft.net>
References: <cover.1384492269.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	john.r.fastabend@intel.com, vyasevich@gmail.com
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60356 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab3KOW4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:56:38 -0500
In-Reply-To: <cover.1384492269.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 15 Nov 2013 06:18:30 +0100 (CET)

> A customer of ours encountered a problem with LRO on an ixgbe network
> card. Analysis showed that it was a known conflict of forwarding and LRO
> but the forwarding was enabled in an LXC container where only a macvlan
> was, not the ethernet device itself.
> 
> I believe the solution is exactly the same as what we do for "normal"
> (802.1q) VLAN devices: if dev_disable_lro() is called for such device,
> LRO is disabled on the underlying "real" device instead.
> 
> v2: adapt to changes merged from net-next
> 
> v3: use BUG() in macvlan_dev_real_dev() if compiled without macvlan

Series applied, thanks Michal.
