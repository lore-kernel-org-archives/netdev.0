From: "David S. Miller" <davem@redhat.com>
Subject: Re: BUG or not? GFP_KERNEL with interrupts disabled.
Date: Thu, 27 Mar 2003 10:07:00 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327.100700.23575723.davem@redhat.com>
References: <20030327.095537.26269606.davem@redhat.com>
	<Pine.LNX.4.44.0303271002420.29205-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulik.hen@intel.com, dane@aiinet.com,
   bonding-devel@lists.sourceforge.net, bonding-announce@lists.sourceforge.net,
   netdev@oss.sgi.com, linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
   mingo@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@transmeta.com
In-Reply-To: <Pine.LNX.4.44.0303271002420.29205-100000@home.transmeta.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Linus Torvalds <torvalds@transmeta.com>
   Date: Thu, 27 Mar 2003 10:04:52 -0800 (PST)

   I'd suggest making it a counting warning (with a static counter per
   local-bh-enable macro expansion) and adding it to local_bh_enable() -
   otherwise it will only BUG()  when the (potentially rare) condition
   happens - instead of always giving a nice backtrace of exact problem 
   spots.

Ok, maybe it's time to move local_bh_enable() out of line, it's
getting large and it's expanded in hundreds of places.
