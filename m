From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 32/58] isdn/gigaset: Convert timers to use timer_setup()
Date: Thu, 19 Oct 2017 23:03:22 +0200
Message-ID: <1508447002.2274.14.camel@tiscali.nl>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
         <1508200182-104605-33-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Karsten Keil <isdn@linux-pingi.de>,
        Johan Hovold <johan@kernel.org>,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-33-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-10-16 at 17:29 -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.

Acked-by: Paul Bolle <pebolle@tiscali.nl>

For the record: this patch made me nervous but survived the rigorous testing I
threw at it. (Ie, dialing up using bas_gigaset and downloading almost 20 MB in
just over an hour. Whoot! That's more than good enough to ack this patch.)

There was some cleanup I had in mind to make this patch more straightforward.
But that can wait until someone finds a way to hit an issue with this patch.
We'll see.

Thanks,


Paul Bolle
