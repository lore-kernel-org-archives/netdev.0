From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] spinlock badness in last dongle changes.
Date: Tue, 7 Oct 2003 19:03:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031008020331.GA19007@bougret.hpl.hp.com>
References: <20031006222631.1934f8e1.shemminger@osdl.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031006222631.1934f8e1.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 06, 2003 at 10:26:31PM -0700, Stephen Hemminger wrote:
> On 2.6.0-test6 bk latest, rmmod of irda hangs on SMP...
> 
> A couple of locking problems happened when converted from using
> hashbin lock outside of irqueue.  First, the lock was never initialized;
> Second, the lock was being unlocked after the hashbin was free.
> 
> Since the hashbin of dongles should be empty (ie all dongle unregistered)
> don't really need locking there, so just warn if we find anything...

	I've recompiled my kernel with this patch and the trouble
modprobing the dongle driver went away.
	Thanks !

	Jean
