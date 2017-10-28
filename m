From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: chelsio/cxgb*: Convert timers to use
 timer_setup()
Date: Sat, 28 Oct 2017 19:21:00 +0900 (KST)
Message-ID: <20171028.192100.814901787143417610.davem@davemloft.net>
References: <20171027055453.GA101265@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh@chelsio.com, ganeshgr@chelsio.com, leedom@chelsio.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027055453.GA101265@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:54:53 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Ganesh Goudar <ganeshgr@chelsio.com>
> Cc: Casey Leedom <leedom@chelsio.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
