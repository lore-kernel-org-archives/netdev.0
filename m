From: Jens Axboe <axboe@suse.de>
Subject: Re: Fw: kernel BUG at net/core/skbuff.c:1028!
Date: Thu, 8 May 2003 10:34:05 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030508083405.GM823@suse.de>
References: <20030507.042003.26512841.davem@redhat.com> <20030508012101.36E012C01B@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, laforge@netfilter.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <20030508012101.36E012C01B@lists.samba.org>
List-Id: netdev.vger.kernel.org

On Thu, May 08 2003, Rusty Russell wrote:
> In message <20030507.042003.26512841.davem@redhat.com> you write:
> > It has to be from some of the skb linearization changes.
> > I can't think of any other change we've made that would
> > make this start to happen.
> 
> Yep, culprit is obvious stupid bug.  This indicates a serious lack of
> testing on my part 8(

One would think so, since it doesn't even get to the login :)

> Jens, does this help?

[snip]

Nope, it still dies hard. I didn't log the oops this time (box is
headless and I need to move it to do so), but it hung hard before it was
done booting.

Want me to log a new oops?

-- 
Jens Axboe
