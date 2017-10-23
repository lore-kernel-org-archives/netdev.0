From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/gigaset: Provide cardstate context for bas timer
 callbacks
Date: Mon, 23 Oct 2017 03:12:47 +0100 (WEST)
Message-ID: <20171023.031247.1142312234606249877.davem@davemloft.net>
References: <20171020204708.GA58150@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, isdn@linux-pingi.de, johan@kernel.org,
        linux-kernel@vger.kernel.org,
        gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171020204708.GA58150@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Fri, 20 Oct 2017 13:47:08 -0700

> While the work callback uses the urb to find cardstate from bas_cardstate,
> this may not be valid for timer callbacks. Instead, introduce a direct
> pointer back to the cardstate from bas_cardstate for use in timer
> callbacks.
> 
> Reported-by: Paul Bolle <pebolle@tiscali.nl>
> Fixes: 4cfea08e6251 ("isdn/gigaset: Convert timers to use timer_setup()")
> Cc: Paul Bolle <pebolle@tiscali.nl>
> Cc: Karsten Keil <isdn@linux-pingi.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Johan Hovold <johan@kernel.org>
> Cc: gigaset307x-common@lists.sourceforge.net
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied to net-next.
