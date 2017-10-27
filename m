From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: wan/sdla: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:10:31 +0900 (KST)
Message-ID: <20171027.121031.236504250486885524.davem@davemloft.net>
References: <20171025105359.GA146645@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: allen.lkml@gmail.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105359.GA146645@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:53:59 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Tobias Klauser <tklauser@distanz.ch>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
