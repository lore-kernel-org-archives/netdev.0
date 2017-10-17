From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH 07/58] net/usb/usbnet: Convert timers to use
 timer_setup()
Date: Tue, 17 Oct 2017 12:30:02 +0200
Message-ID: <1508236202.9770.8.camel@suse.com>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
         <1508200182-104605-8-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-8-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, den 16.10.2017, 17:28 -0700 schrieb Kees Cook:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly. Since the callback is called from
> both a timer and a tasklet, adjust the tasklet to pass the timer address
> too. When tasklets have their .data field removed, this can be refactored
> to call a central function after resolving the correct container_of() for a
> separate callback function for timer and tasklet.
> 
> Cc: Oliver Neukum <oneukum@suse.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>
Acked-by: Oliver Neukum <oneukum@suse.com>
