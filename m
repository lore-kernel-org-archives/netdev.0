From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: fix crash while ethtool -t
Date: Tue, 06 Dec 2011 13:22:06 -0500 (EST)
Message-ID: <20111206.132206.70802703661244687.davem@davemloft.net>
References: <1323173112-30577-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60252 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753086Ab1LFSWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:22:08 -0500
In-Reply-To: <1323173112-30577-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 6 Dec 2011 14:05:12 +0200

> commit 2df1a70aaf70e8dff11b89b938a5f317556ee640  "bnx2x: Support
> for byte queue limits" has introduced an asymmetry in usage of
> netdev_tx_completed_queue and netdev_tx_sent_queue. Missing
> call to netdev_tx_sent_queue causes the crash during ethtool -t.
> 
> The patch adds the missing call.
> 
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
