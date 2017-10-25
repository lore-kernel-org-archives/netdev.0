From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_packet: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 13:03:57 +0900 (KST)
Message-ID: <20171025.130357.911908118877080518.davem@davemloft.net>
References: <20171024084626.GA23908@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, willemb@google.com, maloney@google.com,
        jarno@ovn.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084626.GA23908@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:46:26 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Mike Maloney <maloney@google.com>
> Cc: Jarno Rajahalme <jarno@ovn.org>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
