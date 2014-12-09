From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: fix incorrect rcu_read_unlock() in
 vnet_start_xmit()
Date: Mon, 08 Dec 2014 21:55:55 -0500 (EST)
Message-ID: <20141208.215555.1499035232431905485.davem@davemloft.net>
References: <54866271.1020005@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sowmini.varadhan@oracle.com,
	rashmi.narasimhan@oracle.com
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752455AbaLICz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 21:55:57 -0500
In-Reply-To: <54866271.1020005@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Mon, 08 Dec 2014 21:46:09 -0500

> This patch removes an extra rcu_read_unlock() on an allocation failure
> in vnet_skb_shape(). The needed rcu_read_unlock() is already done in
> the out_dropped label.
> 
> Reported-by: Rashmi Narasimhan <rashmi.narasimhan@oracle.com>
> Signed-off-by: David L Stevens <david.stevens@oracle.com>

Applied, thanks.
