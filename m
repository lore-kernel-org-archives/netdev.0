From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] udptunnels: Call handle_offloads after inserting
 vlan tag.
Date: Thu, 09 Apr 2015 14:57:09 -0400 (EDT)
Message-ID: <20150409.145709.1076905748131956555.davem@davemloft.net>
References: <1428603554-62449-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932623AbbDIS5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 14:57:12 -0400
In-Reply-To: <1428603554-62449-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu,  9 Apr 2015 11:19:14 -0700

> handle_offloads() calls skb_reset_inner_headers() to store
> the layer pointers to the encapsulated packet. However, we
> currently push the vlag tag (if there is one) onto the packet
> afterwards. This changes the MAC header for the encapsulated
> packet but it is not reflected in skb->inner_mac_header, which
> breaks GSO and drivers which attempt to use this for encapsulation
> offloads.
> 
> Fixes: 1eaa8178 ("vxlan: Add tx-vlan offload support.")
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied and queued up for -stable, thanks.
