From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: set sin_port for addr param when checking
 duplicate address
Date: Sun, 26 Feb 2017 21:25:05 -0500 (EST)
Message-ID: <20170226.212505.1113255842286618172.davem@davemloft.net>
References: <a46d62002d14e8ff4a25d647600bb3d038c2c772.1487920726.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751319AbdB0Cco (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 21:32:44 -0500
In-Reply-To: <a46d62002d14e8ff4a25d647600bb3d038c2c772.1487920726.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 24 Feb 2017 15:18:46 +0800

> Commit b8607805dd15 ("sctp: not copying duplicate addrs to the assoc's
> bind address list") tried to check for duplicate address before copying
> to asoc's bind_addr list from global addr list.
> 
> But all the addrs' sin_ports in global addr list are 0 while the addrs'
> sin_ports are bp->port in asoc's bind_addr list. It means even if it's
> a duplicate address, af->cmp_addr will still return 0 as the their
> sin_ports are different.
> 
> This patch is to fix it by setting the sin_port for addr param with
> bp->port before comparing the addrs.
> 
> Fixes: b8607805dd15 ("sctp: not copying duplicate addrs to the assoc's bind address list")
> Reported-by: Wei Chen <weichen@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable, thanks.
