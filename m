From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dccp: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 12:59:33 +0900 (KST)
Message-ID: <20171025.125933.1786953066924623254.davem@davemloft.net>
References: <20171024084609.GA23862@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerrit@erg.abdn.ac.uk, soheil@google.com,
        hannes@stressinduktion.org, edumazet@google.com,
        dccp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751987AbdJYD7i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 23:59:38 -0400
In-Reply-To: <20171024084609.GA23862@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:46:09 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly. Adds a pointer back to the sock.
> 
> Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: dccp@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
