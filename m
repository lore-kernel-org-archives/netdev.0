From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: sis: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 13:22:46 +0900 (KST)
Message-ID: <20171025.132246.1680098690737632849.davem@davemloft.net>
References: <20171024084652.GA23986@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, venza@brownhat.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43264 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751973AbdJYEWu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 00:22:50 -0400
In-Reply-To: <20171024084652.GA23986@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:46:52 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Daniele Venzano <venza@brownhat.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
