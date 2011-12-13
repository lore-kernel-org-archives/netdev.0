From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] be2net: refactor/cleanup vf configuration
 code
Date: Tue, 13 Dec 2011 13:34:58 -0500 (EST)
Message-ID: <20111213.133458.596791713936549430.davem@davemloft.net>
References: <1323773930-6617-1-git-send-email-sathya.perla@emulex.com>
	<1323773930-6617-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab1LMSfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:35:02 -0500
In-Reply-To: <1323773930-6617-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 13 Dec 2011 16:28:50 +0530

> - use adapter->num_vfs (and not the module param) to store the actual
> number of vfs created. Use the same variable to reflect SRIOV
> enable/disable state. So, drop the adapter->sriov_enabled field.
> 
> - use for_all_vfs() macro in VF configuration code
> 
> - drop the "vf_" prefix for the fields of be_vf_cfg; the prefix is
> redundant and removing it helps reduce line wrap
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>

Applied.
