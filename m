From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: hamradio/yam: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:09:44 +0900 (KST)
Message-ID: <20171027.120944.2011577729863667153.davem@davemloft.net>
References: <20171025105120.GA146533@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpr@f6fbb.org, linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105120.GA146533@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:20 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly. Initialization was entirely missing.
> 
> Cc: Jean-Paul Roubelat <jpr@f6fbb.org>
> Cc: linux-hams@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
