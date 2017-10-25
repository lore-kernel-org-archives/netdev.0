From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: LLC: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 12:06:48 +0900 (KST)
Message-ID: <20171025.120648.97365625101010846.davem@davemloft.net>
References: <20171024084548.GA23776@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, ishkamiel@gmail.com,
        paulmck@linux.vnet.ibm.com, elena.reshetova@intel.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084548.GA23776@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:45:48 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Hans Liljestrand <ishkamiel@gmail.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied, thanks.
