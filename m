From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] drivers/net: amd: Convert timers to use timer_setup()
Date: Sat, 28 Oct 2017 19:20:10 +0900 (KST)
Message-ID: <20171028.192010.178447931249528043.davem@redhat.com>
References: <20171027055438.GA88997@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, allen.lkml@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59320 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdJ1KUX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 06:20:23 -0400
In-Reply-To: <20171027055438.GA88997@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:54:38 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Tom Lendacky <thomas.lendacky@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
