From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Thu, 28 Jul 2016 01:31:02 +0100
Message-ID: <20160728003102.GS2356@ZenIV.linux.org.uk>
References: <201607271032.u6RAWPcS008174@sdf.org>
 <4dbfebe8136bc963b5b51463d6887db4@triadic.us>
 <87c4ed555bcb4229f2334f6f2bb69bcb@triadic.us>
 <20160727.164543.1466564919313003461.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexmcwhirter@triadic.us, rlwinm@sdf.org, chunkeey@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160727.164543.1466564919313003461.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 04:45:43PM -0700, David Miller wrote:

> > I highly expect both my issue and OP's issue to revolve not around
> > commit e5a4b0bb803b specifically, but around other code that no longer
> > behaves as expected because of it.
> 
> Indeed, and that fault address rounding bug occurs two other times
> in arch/sparc/lib/user_fixup.c
> 
> The mentioned patchwork patch should fix the bug and I'll get that
> into my sparc tree, merged, and queued up for -stable ASAP.

Plausible for sparc, but I don't see similar __copy_to_user_inatomic()
bugs in case of x86_64...
