From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: sxgbe: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 12:10:14 +0900 (KST)
Message-ID: <20171027.121014.2017945217800050930.davem@davemloft.net>
References: <20171025105320.GA146603@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171025105320.GA146603@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Wed, 25 Oct 2017 03:53:20 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Byungho An <bh74.an@samsung.com>
> Cc: Girish K S <ks.giri@samsung.com>
> Cc: Vipul Pandya <vipul.pandya@samsung.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
