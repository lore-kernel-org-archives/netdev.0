From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] bond_alb: don't disable softirq under bond_alb_xmit
Date: Wed, 11 Jan 2012 12:52:46 -0800 (PST)
Message-ID: <20120111.125246.979686086126749318.davem@davemloft.net>
References: <1326146497-27711-1-git-send-email-maxim.uvarov@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	amwang@redhat.com
To: maxim.uvarov@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752776Ab2AKUxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 15:53:06 -0500
In-Reply-To: <1326146497-27711-1-git-send-email-maxim.uvarov@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxim Uvarov <maxim.uvarov@oracle.com>
Date: Mon,  9 Jan 2012 14:01:37 -0800

> No need to lock soft irqs under bond_alb_xmit()
> which already has softirq disabled.
> 
> Changes:
> 1. add non-bh/bh version to tlb_clear_slave()
> 
> 2. represent BH and non BH hash table locks
> _lock_rx_hashtbl_bh/_unlock_rx_hashtbl_bh
> _lock_rx_hashtbl/_unlock_rx_hashtbl
> _lock_tx_hashtbl_bh/_unlock_tx_hashtbl_bh
> _lock_tx_hashtbl/_unlock_tx_hashtbl
> 
> Signed-off-by: Maxim Uvarov <maxim.uvarov@oracle.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
