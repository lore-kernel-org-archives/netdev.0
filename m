From: Robert Love <rml@tech9.net>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: 27 Mar 2003 14:52:11 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1048794730.775.14.camel@localhost>
References: <20030327.111012.23672715.davem@redhat.com>
	 <Pine.LNX.4.44.0303271120230.31459-100000@home.transmeta.com>
	 <20030327.113933.123322481.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@transmeta.com, dane@aiinet.com, shmulik.hen@intel.com,
	bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030327.113933.123322481.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 2003-03-27 at 14:39, David S. Miller wrote:

> I hadn't considered this, good idea.  I'm trying this out right now.

I hope it works.  I have a sinking feeling we call it some places that
may have interrupts disabled...

> Someone should backport the might_sleep() stuff to 2.4.x, it's very
> useful.

Would be nice, but for the maximum effect we need kernel preemption
(which keeps track of atomicity via preempt_count).  I doubt we want to
go there for 2.4.

	Robert Love

