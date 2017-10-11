From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hdlc: Convert timers to use timer_setup()
Date: Wed, 11 Oct 2017 15:19:08 -0700 (PDT)
Message-ID: <20171011.151908.1325409031052082911.davem@davemloft.net>
References: <20171010220833.GA97664@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, tglx@linutronix.de,
        linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171010220833.GA97664@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Tue, 10 Oct 2017 15:08:33 -0700

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly. This adds a pointer back to the
> net_device, and drops needless open-coded resetting of the .function and
> .data fields.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Krzysztof Halasa <khc@pm.waw.pl>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
> This requires commit 686fef928bba ("timer: Prepare to change timer
> callback argument type") in v4.14-rc3, but should be otherwise
> stand-alone.

This doesn't apply cleanly to net-next, please respin.
