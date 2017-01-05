From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xilinx: emaclite: Remove xemaclite_remove_ndev()
Date: Thu, 05 Jan 2017 11:29:49 -0500 (EST)
Message-ID: <20170105.112949.1359328171589263709.davem@davemloft.net>
References: <20170105094136.16989-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michal.simek@xilinx.com,
        soren.brinkmann@xilinx.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761071AbdAEQaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 11:30:05 -0500
In-Reply-To: <20170105094136.16989-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  5 Jan 2017 10:41:36 +0100

> xemaclite_remove_ndev() is a simple wrapper around free_netdev()
> checking for NULL before the call. All possible paths calling
> it are guaranteed to pass a non-NULL argument, so rather call
> free_netdev() directly.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
