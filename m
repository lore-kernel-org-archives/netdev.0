From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2 net-next] sfc: fix an off by one bug
Date: Tue, 07 Feb 2017 14:00:50 -0500 (EST)
Message-ID: <20170207.140050.1152060406801498921.davem@davemloft.net>
References: <60d163b6-0b49-172f-288c-e1712e04a84e@solarflare.com>
        <20170207074431.GA18377@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754530AbdBGTAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:00:51 -0500
In-Reply-To: <20170207074431.GA18377@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 7 Feb 2017 10:44:31 +0300

> This bug is harmless because it's just a sanity check and we always
> pass valid values for "encap_type" but the test is off by one.
> 
> Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: Rebased against last linux-next

Applied, thanks Dan.
