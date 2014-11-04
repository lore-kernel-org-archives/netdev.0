From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv1 net-next] xen-netback: remove unconditional
 pull_skb_tail in guest Tx path
Date: Tue, 04 Nov 2014 16:41:13 -0500 (EST)
Message-ID: <20141104.164113.2265592775058059992.davem@davemloft.net>
References: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	malcolm.crossley@citrix.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbaKDVlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 16:41:18 -0500
In-Reply-To: <1415035431-27485-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Mon, 3 Nov 2014 17:23:51 +0000

> From: Malcolm Crossley <malcolm.crossley@citrix.com>
> 
> Unconditionally pulling 128 bytes into the linear buffer is not
> required. Netback has already grant copied up-to 128 bytes from the
> first slot of a packet into the linear buffer. The first slot normally
> contain all the IPv4/IPv6 and TCP/UDP headers.
> 
> The unconditional pull would often copy frag data unnecessarily.  This
> is a performance problem when running on a version of Xen where grant
> unmap avoids TLB flushes for pages which are not accessed.  TLB
> flushes can now be avoided for > 99% of unmaps (it was 0% before).
> 
> Grant unmap TLB flush avoidance will be available in a future version
> of Xen (probably 4.6).
> 
> Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Now that this has been discussed a bit, it is possible to get an ack or two?

Thanks.
