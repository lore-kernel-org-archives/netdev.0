From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH 54/58] net/xen-netback: Convert timers to use
 timer_setup()
Date: Fri, 20 Oct 2017 17:16:02 +0100
Message-ID: <20171020161602.flvjloljfc7fcjcv@citrix.com>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
 <1508200182-104605-55-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Liu <wei.liu2@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        <linux-kernel@vger.kernel.org>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1508200182-104605-55-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 16, 2017 at 05:29:38PM -0700, Kees Cook wrote:
> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: xen-devel@lists.xenproject.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Wei Liu <wei.liu2@citrix.com>
