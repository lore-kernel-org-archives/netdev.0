From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] drivers/net: appletalk/cops: Convert timers to use
 timer_setup()
Date: Sat, 28 Oct 2017 19:20:26 +0900 (KST)
Message-ID: <20171028.192026.718854596198328464.davem@redhat.com>
References: <20171027055445.GA96228@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: allen.lkml@gmail.com, dhowells@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027055445.GA96228@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Thu, 26 Oct 2017 22:54:45 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Allen Pais <allen.lkml@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: David Howells <dhowells@redhat.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
