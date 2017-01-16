From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 13:25:07 -0500 (EST)
Message-ID: <20170116.132507.247451258073906225.davem@davemloft.net>
References: <1484589810-13723-1-git-send-email-mayhs11saini@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        everest-linux-l2@cavium.com, netdev@vger.kernel.org
To: mayhs11saini@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751133AbdAPSZI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 13:25:08 -0500
In-Reply-To: <1484589810-13723-1-git-send-email-mayhs11saini@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shyam Saini <mayhs11saini@gmail.com>
Date: Mon, 16 Jan 2017 23:33:30 +0530

> Use eth_zero_addr to assign zero address to the given address array
> instead of memset when the second argument in memset is address
> of zero. Also, it makes the code clearer
> 
> Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>

This doesn't apply cleanly to net-next, please respin.
