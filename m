From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Fix pause frame count in
 t4_get_port_stats
Date: Tue, 05 Sep 2017 14:28:33 -0700 (PDT)
Message-ID: <20170905.142833.1662741216295283523.davem@davemloft.net>
References: <1504504056-21956-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbdIEV2e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 17:28:34 -0400
In-Reply-To: <1504504056-21956-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Mon,  4 Sep 2017 11:17:36 +0530

> MPS_STAT_CTL[CountPauseStatTx] and MPS_STAT_CTL[CountPauseStatRx]
> only control whether or not Pause Frames will be counted as part
> of the 64-Byte Tx/Rx Frame counters.  These bits do not control
> whether Pause Frames are counted in the Total Tx/Rx Frames/Bytes
> counters.
> 
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.
