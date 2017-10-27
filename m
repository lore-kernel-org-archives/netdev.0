From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: realtek: Convert timers to use
 timer_setup()
Date: Fri, 27 Oct 2017 12:10:08 +0900 (KST)
Message-ID: <20171027.121008.919367172179684747.davem@davemloft.net>
References: <20171025105312.GA146589@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, dhowells@redhat.com,
        jay.vosburgh@canonical.com, allen.lkml@gmail.com,
        edumazet@google.com, tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105312.GA146589@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:53:12 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Howells <dhowells@redhat.com>
> Cc: Jay Vosburgh <jay.vosburgh@canonical.com>
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Tobias Klauser <tklauser@distanz.ch>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
