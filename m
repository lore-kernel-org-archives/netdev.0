From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: avoid stall while shutting down the
 adapter
Date: Thu, 21 Sep 2017 15:35:21 -0700 (PDT)
Message-ID: <20170921.153521.376585753851115652.davem@davemloft.net>
References: <1505978447-14944-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751728AbdIUWfW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 18:35:22 -0400
In-Reply-To: <1505978447-14944-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Thu, 21 Sep 2017 12:50:47 +0530

> do not wait for completion while deleting the filters
> when the adapter is shutting down because we may not get
> the response as interrupts will be disabled.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thanks.
