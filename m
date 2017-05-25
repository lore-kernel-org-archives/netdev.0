From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: jme: Remove unused functions
Date: Thu, 25 May 2017 12:59:28 -0400 (EDT)
Message-ID: <20170525.125928.145593632895584679.davem@davemloft.net>
References: <20170524002751.172595-1-mka@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cooldavid@cooldavid.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dianders@chromium.org
To: mka@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935158AbdEYQ7f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 12:59:35 -0400
In-Reply-To: <20170524002751.172595-1-mka@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <mka@chromium.org>
Date: Tue, 23 May 2017 17:27:51 -0700

> The functions jme_restart_tx_engine(), jme_pause_rx() and
> jme_resume_rx() are not used. Removing them fixes the following warnings
> when building with clang:
> 
> drivers/net/ethernet/jme.c:694:1: error: unused function
>     'jme_restart_tx_engine' [-Werror,-Wunused-function]
> 
> drivers/net/ethernet/jme.c:2393:20: error: unused function
>     'jme_pause_rx' [-Werror,-Wunused-function]
> 
> drivers/net/ethernet/jme.c:2406:20: error: unused function
>     'jme_resume_rx' [-Werror,-Wunused-function]
> 
> Signed-off-by: Matthias Kaehlcke <mka@chromium.org>

Applied to net-next.
