From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Add 32bit emulation for wireless
Date: Mon, 19 Jan 2004 12:26:57 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119122657.3b432583.davem@redhat.com>
References: <20040119123343.GA16292@colin2.muc.de>
	<20040119123945.A32623@infradead.org>
	<20040119141041.2cccbc3d.ak@suse.de>
	<20040119055615.4380e157.davem@redhat.com>
	<20040119153919.14102937.ak@suse.de>
	<20040119063921.586b37ac.davem@redhat.com>
	<20040119155412.2bffee5a.ak@suse.de>
	<20040119194943.GA9360@bougret.hpl.hp.com>
	<20040119210132.0c52df58.ak@suse.de>
	<20040119201912.GA9701@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, ak@suse.de, hch@infradead.org, ak@colin2.muc.de,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040119201912.GA9701@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 19 Jan 2004 12:19:12 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> 	This analogy doesn't work. If your network is wireless, you
> won't connect to it with an Ethernet card (and vice versa). A fully 64
> bits userspace has only very minor downside, and most users won't see
> any difference. If we follow your line of thought, we should all be
> using a 16bit userspace on i386 (more compact, more compatible).

I think the situation is different.  On several 64-bit platforms we encourage
using 32-bit compilation and binaries by default because:

1) they're a lot faster than their 64-bit counterparts

2) they're a lot smaller than their 64-bit counterparts

3) 64-bits buys them absolutely nothing

Therefore the 32-bit compatability layer must be as fully supportive as humanly
possible.  Most 64-bit platforms still have %99 32-bit distributions.

This has been discussed to death a million times, please accept the situation and
work towards getting the 32-bit compat stuff working for these wireless ioctls.
We wouldn't be working on this if "just compile as 64-bit" we an acceptable solution
now would we :)
