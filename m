From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: handle serial flash interrupt
Date: Tue, 13 Jun 2017 16:11:32 -0400 (EDT)
Message-ID: <20170613.161132.1501937364224601071.davem@davemloft.net>
References: <1497381343-31705-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com,
        rahul.lakkireddy@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753653AbdFMULe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 16:11:34 -0400
In-Reply-To: <1497381343-31705-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Wed, 14 Jun 2017 00:45:43 +0530

> If SF bit is not cleared in PL_INT_CAUSE, subsequent non-data
> interrupts are not raised.  Enable SF bit in Global Interrupt
> Mask and handle it as non-fatal and hence eventually clear it.
> 
> Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
