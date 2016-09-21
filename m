From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] cxgb4/cxgb4vf: Allocate more queues for 25G and
 100G adapter
Date: Wed, 21 Sep 2016 00:50:03 -0400 (EDT)
Message-ID: <20160921.005003.115968805012717166.davem@davemloft.net>
References: <1474353052-19370-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33744 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbcIUEuG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 00:50:06 -0400
In-Reply-To: <1474353052-19370-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 20 Sep 2016 12:00:52 +0530

> We were missing check for 25G and 100G while checking port speed,
> which lead to less number of queues getting allocated for 25G & 100G
> adapters and leading to low throughput. Adding the missing check for
> both NIC and vNIC driver.
> 
> Also fixes port advertisement for 25G and 100G in ethtool output.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
> ---
> V2: Missed 25G in the first one

Applied.
