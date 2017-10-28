From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: natsemi: Convert timers to use
 timer_setup()
Date: Sat, 28 Oct 2017 19:22:20 +0900 (KST)
Message-ID: <20171028.192220.1723288623162428416.davem@davemloft.net>
References: <20171027055527.GA122213@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: allen.lkml@gmail.com, edumazet@google.com, tremyfr@gmail.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027055527.GA122213@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:55:27 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Philippe Reynes <tremyfr@gmail.com>
> Cc: Wei Yongjun <weiyongjun1@huawei.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
