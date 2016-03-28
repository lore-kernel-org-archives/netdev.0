From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: fix software timestamping
Date: Sun, 27 Mar 2016 22:42:09 -0400 (EDT)
Message-ID: <20160327.224209.1094647396845524866.davem@davemloft.net>
References: <1459074122-6964-1-git-send-email-LinoSanfilippo@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044AbcC1CmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 22:42:11 -0400
In-Reply-To: <1459074122-6964-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sun, 27 Mar 2016 12:22:02 +0200

> In ravb_start_xmit dont call skb_tx_timestamp only when hardware
> timestamping is requested: in the latter case software timestamps are
> suppressed and thus the call of skb_tx_timestamp does not have any effect.
> 
> Instead call skb_tx_timestamp unconditionally in ravb_start_xmit, since
> the function checks itself if software timestamping is required or should
> be skipped due to hardware timestamping.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

Applied, thanks.
