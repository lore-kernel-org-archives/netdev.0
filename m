From: "David S. Miller" <davem@redhat.com>
Subject: Re: Chaotic structure of the net headers?
Date: Wed, 05 Mar 2003 15:03:44 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030305.150344.50145701.davem@redhat.com>
References: <20030305225441.GO20423@fs.tum.de>
	<1046905834.17778.400.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@fs.tum.de, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Rod.VanMeter@nokia.com
In-Reply-To: <1046905834.17778.400.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rod Van Meter <Rod.VanMeter@nokia.com>
   Date: 05 Mar 2003 15:10:35 -0800
   
   Does it make sense to have two forms, one kernel, one user?  I haven't
   e.g. followed the desired include chain.  If we wanted to merge the
   uses, the former form and include location would probably have to be
   used.
   
   I've been looking into this.  There are a *few* things missing from the
   2292 support.  AFAICT, it's just a handful of functions/macros for
   manipulating option headers that need to be added.

Actually forget all my comments, GLIBC headers are where
the advanced socket API requirements for headers should
be applied.

And since this is only used in the kernel, there is no need
for the NEXTHDR_* if it trully just duplicates the IPPROTO_*
defines.

I'm willing to accept a cleanup patch of this nature, sure.
