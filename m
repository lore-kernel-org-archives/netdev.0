From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: hippi: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 12:09:50 +0900 (KST)
Message-ID: <20171027.120950.1895762684750742049.davem@davemloft.net>
References: <20171025105129.GA146547@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@trained-monkey.org, linux-hippi@sunsite.dk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdJ0DJx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 23:09:53 -0400
In-Reply-To: <20171025105129.GA146547@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:29 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Jes Sorensen <jes@trained-monkey.org>
> Cc: linux-hippi@sunsite.dk
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
