From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] drivers/net: 8390: Convert timers to use timer_setup()
Date: Sat, 28 Oct 2017 19:19:55 +0900 (KST)
Message-ID: <20171028.191955.133638188480855958.davem@redhat.com>
References: <20171027055425.GA80645@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39502 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751000AbdJ1KUF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 28 Oct 2017 06:20:05 -0400
In-Reply-To: <20171027055425.GA80645@beast>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:54:25 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
