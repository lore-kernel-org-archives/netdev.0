From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] cxgb4: Add support for loopback between
 VI of same port
Date: Sun, 17 May 2015 23:46:13 -0400 (EDT)
Message-ID: <20150517.234613.463972132331185537.davem@davemloft.net>
References: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
	<1431859523-7423-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51451 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbbERDqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:46:15 -0400
In-Reply-To: <1431859523-7423-2-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Sun, 17 May 2015 16:15:21 +0530

> We now have a new cxgb4 module parameter "tx_vf" that when set
> to a non-zero value, causes cxgb4 to use the "Virtual Machine" version
> of the firmware Ethernet TX Packet Work Request (FW_ETH_TX_PKT_VM_WR)
> instead of the "normal" default non-VM Work Request (FW_ETH_TX_PKT_WR).
> This allows TX Packets sent by the cxgb4 PF Driver to be subject to the
> firmware's MPS TCAM Lookup and therefore elligable for loop back to other
> Virtual interfaces on the same port. This is useful for communicating with
> Virtual machines running the VF Driver (cxgb4vf) and also for interesting
> layered service applications. Enabling it by default lowers the
> performance, so maybe module parameter is the right way to this.
> 
> Based on original work by Casey Leedom <leedom@chelsio.com>
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Sorry, module parameters are veboten.

Especially for settings like this which are guaranteed to be
interesting for other NIC drivers, not just your's.

I'm really tired of explaining this to driver authors.  Just
don't even try to push a module parameter past me.

Thanks.
