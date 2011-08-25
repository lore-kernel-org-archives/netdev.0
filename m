From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmveth: Fix leak when recycling skb and hypervisor
 returns error
Date: Wed, 24 Aug 2011 17:43:53 -0700 (PDT)
Message-ID: <20110824.174353.1962229766905714384.davem@davemloft.net>
References: <20110825092019.777aea6e@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1HYAn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:43:58 -0400
In-Reply-To: <20110825092019.777aea6e@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 25 Aug 2011 09:20:19 +1000

> If h_add_logical_lan_buffer returns an error we need to free
> the skb.
> 
> Signed-off-by: Anton Blanchard <anton@samba.org>
> Cc: stable <stable@kernel.org>

Please generate this patch against Linus's tree, instead of -next

Thanks!
