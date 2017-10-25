From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ax25: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 12:04:19 +0900 (KST)
Message-ID: <20171025.120419.228677358395538846.davem@davemloft.net>
References: <20171024084539.GA23749@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024084539.GA23749@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 24 Oct 2017 01:45:39 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Joerg Reuter <jreuter@yaina.de>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: linux-hams@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied.
