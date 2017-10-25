From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet/sfc: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 12:57:47 +0900 (KST)
Message-ID: <20171025.125747.1676821059165904517.davem@davemloft.net>
References: <20171024084559.GA23827@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, edumazet@google.com, jiri@mellanox.com,
        jhs@mojatatu.com, mingo@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084559.GA23827@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:45:59 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> Cc: Edward Cree <ecree@solarflare.com>
> Cc: Bert Kenward <bkenward@solarflare.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
