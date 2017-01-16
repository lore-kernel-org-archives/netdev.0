From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Shutdown adapter if firmware times out
 or errors out
Date: Mon, 16 Jan 2017 13:35:43 -0500 (EST)
Message-ID: <20170116.133543.71724184955414718.davem@davemloft.net>
References: <1484324726-29590-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
        ganeshgr@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAPSfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:35:45 -0500
In-Reply-To: <1484324726-29590-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 13 Jan 2017 21:55:26 +0530

> Perform an emergency shutdown of the adapter and stop it from
> continuing any further communication on the ports or DMA to the
> host. This is typically used when the adapter and/or firmware
> have crashed and we want to prevent any further accidental
> communication with the rest of the world. This will also force
> the port Link Status to go down -- if register writes work --
> which should help our peers figure out that we're down.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thank you.
