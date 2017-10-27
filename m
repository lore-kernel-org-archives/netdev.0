From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: netronome: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:09:56 +0900 (KST)
Message-ID: <20171027.120956.1944875051120489377.davem@davemloft.net>
References: <20171025105138.GA146561@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, jiri@mellanox.com, jhs@mojatatu.com,
        simon.horman@netronome.com, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105138.GA146561@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:51:38 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jiri Pirko <jiri@mellanox.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Simon Horman <simon.horman@netronome.com>
> Cc: oss-drivers@netronome.com
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
