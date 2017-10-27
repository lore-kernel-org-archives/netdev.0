From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: wan/lmc: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:10:25 +0900 (KST)
Message-ID: <20171027.121025.11740019725813069.davem@davemloft.net>
References: <20171025105353.GA146631@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: allen.lkml@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105353.GA146631@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:53:53 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
