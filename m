From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 11:39:33 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.113933.123322481.davem@redhat.com>
References: <20030327.111012.23672715.davem@redhat.com>
	<Pine.LNX.4.44.0303271120230.31459-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dane@aiinet.com, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, bonding-announce@lists.sourceforge.net,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com
In-Reply-To: <Pine.LNX.4.44.0303271120230.31459-100000@home.transmeta.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Linus Torvalds <torvalds@transmeta.com>
   Date: Thu, 27 Mar 2003 11:22:55 -0800 (PST)

   	if (gfp_mask & __GFP_WAIT)
   		might_sleep();
   
   and might_sleep() should be updated.
   
   Anybody want to try that and see whether things break horribly?

I hadn't considered this, good idea.  I'm trying this out right now.

Someone should backport the might_sleep() stuff to 2.4.x, it's very
useful.
