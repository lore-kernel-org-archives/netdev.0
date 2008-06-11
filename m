From: Patrick McManus <mcmanus@ducksong.com>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Wed, 11 Jun 2008 09:10:07 -0400
Message-ID: <1213189807.6442.33.camel@tng>
References: <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
	 <20080603.150344.145518113.davem@davemloft.net>
	 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
	 <20080610.153252.252676827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, mingo@elte.hu, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, rjw@sisk.pl,
	akpm@linux-foundation.org, johnpol@2ka.mipt.ru, vgusev@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754868AbYFKNKY@vger.kernel.org>
In-Reply-To: <20080610.153252.252676827.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2008-06-10 at 15:32 -0700, David Miller wrote:

> If we cannot find a simple and easy way to deal with this locking
> problem, I am reverting the defer-accept changes entirely.  It's not
> the end of the world if this feature has to be deferred to 2.6.27

based on this, plus the comments from vitaliy it is clear that moving
the DA socket to established is pretty tricky. I agree I should address
these things in the >= 27 time frame.

imho we don't need to revert the first two patches:
e4c78840284f3f51b1896cf3936d60a6033c4d2c and
539fae89bebd16ebeafd57a87169bc56eb530d76 .. they have nothing to do with
rearranging states or the locking and they do fix the more notable DA
behavior issues.

-Patrick
