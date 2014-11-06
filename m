From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] enic: update desc properly in rx_copybreak
Date: Thu, 06 Nov 2014 16:42:47 -0500 (EST)
Message-ID: <20141106.164247.1655129194042333323.davem@davemloft.net>
References: <1415267499-25955-1-git-send-email-_govind@gmx.com>
	<1415267499-25955-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, netdev@vger.kernel.org
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaKFVmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:42:49 -0500
In-Reply-To: <1415267499-25955-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu,  6 Nov 2014 15:21:39 +0530

> When we reuse the rx buffer, we need to update the desc. If not hardware sees
> stale value.
> 
> In the following crash, when mtu is changed, hardware sees old rx buffer value
> and crashes on skb_put.
> 
> Fix this by using enic_queue_rq_desc helper function which updates the necessary
> desc.
 ...
> fixes: a03bb56e67c357980dae886683733dab5583dc14 ("enic: implement rx_copybreak")
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Also applied, thanks.
