From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Updated Wireless Extension patches
Date: Tue, 29 Jun 2004 13:41:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629204143.GA11782@bougret.hpl.hp.com>
References: <20040629162339.GA4356@bougret.hpl.hp.com> <20040629194525.GF23191@havoc.gtf.org>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux kernel mailing list <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040629194525.GF23191@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 03:45:25PM -0400, Jeff Garzik wrote:
> 
> Regardless of our recent discussions, I do want to emphasize that I wish
> to maintain the current WE, and its backwards compatibility, for the
> current 2.6.x stable series at the very least.
> 
> So please don't be discouraged from submitting WE patches...

	No problem Jeff ;-) Because of my wife, I have learned to
compromise (I just wish she had learned that as well). I already told
you that the actual delivery mechanism to the driver doesn't matter to
me, what matter to me is the vocabulary and gramar of the API. And
also I want to satisfy the need of both driver authors and userspace.
	So, we are aiming for the same goal, just having slightly
different methods.
	I plan to submit WE-17 to you somewhat soon, because Jouni
needs it, and I've postponed it far too much. There is actually one
change in WE-17 that you should appreciate. WPA and RtNetlink will go
when they are ready, for WPA it depends on Jouni, for RtNetlink on me.

> 	Jeff
> 
> 
> P.S. do associated userland wireless-tools patches exist to make use of
> netlink?  i.e. how have you been testing it?

	Good catch ;-)
	There are some advantage to RtNetlink. Unfortunately,
simplicity is not one. Dealing with RtNetlink is a lot of work
compared to ioctl, as you may discover if you migrate your API to it.
	I have a pretty simple test app. I'm working on a version of
iwlib that would go through RtNetlink, that would enable the full
Wireless Tools to use RtNetlink. I'll try to release that soon.

	Have fun...

	Jean
