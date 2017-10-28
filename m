From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: fealnx: Convert timers to use
 timer_setup()
Date: Sat, 28 Oct 2017 19:21:58 +0900 (KST)
Message-ID: <20171028.192158.2289488041056727681.davem@davemloft.net>
References: <20171027055507.GA110104@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuval.shaia@oracle.com, allen.lkml@gmail.com,
        stephen@networkplumber.org, tremyfr@gmail.com,
        johannes.berg@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751469AbdJ1KWD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 06:22:03 -0400
In-Reply-To: <20171027055507.GA110104@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:55:07 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Philippe Reynes <tremyfr@gmail.com>
> Cc: Johannes Berg <johannes.berg@intel.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
