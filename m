From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: can: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 12:09:38 +0900 (KST)
Message-ID: <20171027.120938.1299376855542654090.davem@davemloft.net>
References: <20171025105114.GA146515@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, mkl@pengutronix.de, allen.lkml@gmail.com,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20171025105114.GA146515@beast>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:14 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: linux-can@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
