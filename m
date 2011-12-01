From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND net/stable] gro: reset vlan_tci on reuse
Date: Wed, 30 Nov 2011 23:32:01 -0500 (EST)
Message-ID: <20111130.233201.156361848115663011.davem@davemloft.net>
References: <1322657238-17159-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org, jesse@nicira.com
To: bpoirier@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025Ab1LAEcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:32:08 -0500
In-Reply-To: <1322657238-17159-1-git-send-email-bpoirier@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.de>
Date: Wed, 30 Nov 2011 07:47:18 -0500

> For drivers using the vlan_gro_frags() interface, a packet with an invalid tci
> leads to GRO_DROP and napi_reuse_skb(). The skb has to be sanitized before
> being reused or we may send an skb with an invalid vlan_tci field up the stack
> where it is not expected.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Cc: Jesse Gross <jesse@nicira.com>

Acked-by: David S. Miller <davem@davemloft.net>
