From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] spinlock badness in last dongle changes.
Date: Tue, 7 Oct 2003 08:29:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007082902.03dc16be.davem@redhat.com>
References: <20031006222631.1934f8e1.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031006222631.1934f8e1.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 6 Oct 2003 22:26:31 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> A couple of locking problems happened when converted from using
> hashbin lock outside of irqueue.  First, the lock was never initialized;
> Second, the lock was being unlocked after the hashbin was free.
> 
> Since the hashbin of dongles should be empty (ie all dongle unregistered)
> don't really need locking there, so just warn if we find anything...

Applied, thanks Stephen.

Jean didn't express his opinion, but if he doesn't like the change
we can just put the fix he prefers on top.
