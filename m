From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: fix memory leak
Date: Tue, 05 Sep 2017 14:28:27 -0700 (PDT)
Message-ID: <20170905.142827.2296553954635308872.davem@davemloft.net>
References: <1504503988-21903-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752312AbdIEV22 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:28:28 -0400
In-Reply-To: <1504503988-21903-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon,  4 Sep 2017 11:16:28 +0530

> do not reuse the loop counter which is used iterate over
> the ports, so that sched_tbl will be freed for all the ports.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied.
