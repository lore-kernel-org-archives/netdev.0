From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: dl2k: Convert timers to use timer_setup()
Date: Thu, 5 Oct 2017 09:40:35 +0200
Message-ID: <20171005074034.GC1370@distanz.ch>
References: <20171005005150.GA23486@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171005005150.GA23486@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-10-05 at 02:51:50 +0200, Kees Cook <keescook@chromium.org> wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jarod Wilson <jarod@redhat.com>
> Cc: Tobias Klauser <tklauser@distanz.ch>
> Cc: Philippe Reynes <tremyfr@gmail.com>
> Cc: netdev@vger.kernel.org
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Kees Cook <keescook@chromium.org>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
