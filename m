From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] i40e: Fix TSO and hw checksums for non-accelerated
 vlan packets.
Date: Sat, 23 Aug 2014 11:43:57 -0700 (PDT)
Message-ID: <20140823.114357.1040666365885664477.davem@davemloft.net>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
	<1408760230-7457-6-git-send-email-vysevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	alexander.h.duyck@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbaHWSn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2014 14:43:59 -0400
In-Reply-To: <1408760230-7457-6-git-send-email-vysevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: vyasevich@gmail.com
Date: Fri, 22 Aug 2014 22:17:07 -0400

> @@ -2295,7 +2295,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
>  		goto out_drop;
>  
>  	/* obtain protocol of skb */
> -	protocol = skb->protocol;
> +	protocol = get_vlan_protocol(skb);

I don't think this even compiles.

It's "vlan_get_protocol" not "get_vlan_protocol".
