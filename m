From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: chelsio/cxgb*: Convert timers to use
 timer_setup()
Date: Sat, 28 Oct 2017 19:21:16 +0900 (KST)
Message-ID: <20171028.192116.1930230306590046073.davem@davemloft.net>
References: <20171027055453.GA101265@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, ganeshgr@chelsio.com, leedom@chelsio.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751759AbdJ1KVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 06:21:22 -0400
In-Reply-To: <20171027055453.GA101265@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:54:53 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Ganesh Goudar <ganeshgr@chelsio.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
