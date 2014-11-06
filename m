From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] enic: handle error condition properly in
 enic_rq_indicate_buf
Date: Thu, 06 Nov 2014 16:42:35 -0500 (EST)
Message-ID: <20141106.164235.1792456068468109139.davem@davemloft.net>
References: <1415267499-25955-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, netdev@vger.kernel.org
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbaKFVmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 16:42:37 -0500
In-Reply-To: <1415267499-25955-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu,  6 Nov 2014 15:21:38 +0530

> In case of error in rx path, we free the buf->os_buf but we do not make it NULL.
> In next iteration we use the skb which is already freed. This causes the
> following crash.
 ...
> fixes: a03bb56e67c357980dae886683733dab5583dc14 ("enic: implement rx_copybreak")
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
