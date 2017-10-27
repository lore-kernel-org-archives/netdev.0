From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: 3com/3c515: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:09:31 +0900 (KST)
Message-ID: <20171027.120931.2193816626439283545.davem@davemloft.net>
References: <20171025105103.GA146494@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, stephen@networkplumber.org,
        johannes.berg@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105103.GA146494@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:03 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Johannes Berg <johannes.berg@intel.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
