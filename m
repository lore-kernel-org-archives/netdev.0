From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prevent "eth0: driver changed get_stats after register"
 lying
Date: Sun, 19 Oct 2003 00:06:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031019000646.19f39f51.davem@redhat.com>
References: <20031018214622.B25375@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Russell King <rmk@arm.linux.org.uk>
In-Reply-To: <20031018214622.B25375@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 18 Oct 2003 21:46:22 +0100
Russell King <rmk@arm.linux.org.uk> wrote:

> We set "dev->last_stats" after we have registered the class device.
> During class device registration, we trigger the hotplug scripts,
> which can in turn bring up the interface.  This in turn checks to
> see if "dev->last_stats == dev->get_stats", and, since we haven't
> set dev->last_stats yet, we complain.
> 
> Here is a patch against 2.6.0-test8 which moves the initialisation
> of last_stats such that we avoid the race.

Looks ok, thanks Russell.
