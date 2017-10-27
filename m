From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: nuvoton: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:10:02 +0900 (KST)
Message-ID: <20171027.121002.2042844769656745749.davem@davemloft.net>
References: <20171025105158.GA146575@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcuos.com@gmail.com, linux-arm-kernel@lists.infradead.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105158.GA146575@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:58 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Wan ZongShun <mcuos.com@gmail.com>
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
