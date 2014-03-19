From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 06/15] i40e/i40evf: enable hardware feature head
 write back
Date: Wed, 19 Mar 2014 14:09:19 -0400 (EDT)
Message-ID: <20140319.140919.1350209156761878583.davem@davemloft.net>
References: <1395200533-16908-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395200533-16908-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, mitch.a.williams@intel.com,
	catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaCSSJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 14:09:20 -0400
In-Reply-To: <1395200533-16908-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 20:42:04 -0700

> +static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
> +{
> +	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
> +	return le32_to_cpu(*(volatile __le32 *)head);

Please put an empty line between local variable declarations and code.

> +static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
> +{
> +	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
> +	return le32_to_cpu(*(volatile __le32 *)head);

Likewise.
