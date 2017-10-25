From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: wan/sbni: Convert timers to use
 timer_setup()
Date: Wed, 25 Oct 2017 13:22:54 +0900 (KST)
Message-ID: <20171025.132254.201094843197435495.davem@davemloft.net>
References: <20171024084700.GA24005@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084700.GA24005@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:47:00 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: David Howells <dhowells@redhat.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
