From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Sun, 25 May 2003 19:29:04 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030525.192904.23037779.davem@redhat.com>
References: <20030522.034058.71558626.davem@redhat.com>
	<1053602138.9475.34.camel@tux.rsn.bth.se>
	<20030523174156.210d7f94.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: akpm@digeo.com
In-Reply-To: <20030523174156.210d7f94.akpm@digeo.com>
List-Id: netdev.vger.kernel.org

   From: Andrew Morton <akpm@digeo.com>
   Date: Fri, 23 May 2003 17:41:56 -0700
   
   a) mips64 and cris seem to have forgotten to implement it.
   
I consider these platforms unmaintained in 2.5.x currently :-)

Without it, several generic things simply don't build.
SCSI tape is one.  Admittedly the rest of the spots are in
obscure or arch specific places.

   b) ppc and ia64 just had to sneak a bit of asm into their version
   
These are just optimizations, and I'm surprised x86 doesn't use
some clever instructions too.

   I get the feeling that we need just a single copy of this guy, in
   <linux/bitops.h>
   
True, I really doubt this is worth optimizing except to be cute.

