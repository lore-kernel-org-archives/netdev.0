From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Make xfrm subsystem optional
Date: Sat, 14 Jun 2003 02:38:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030614.023843.78709528.davem@redhat.com>
References: <20030614091631.GA16993@wotan.suse.de>
	<20030614.022702.41637600.davem@redhat.com>
	<20030614093630.GB16993@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030614093630.GB16993@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Sat, 14 Jun 2003 11:36:30 +0200

   Also when you do use it generically you will hopefully
   discard some old code (like the rt cache?) which may make
   up for the additional bloat. But until that happens having
   both even when not needed doesn't make too much sense.
   
The rtcache will likely be retained as a flow cache lookup
miss handler even once we use the flowcache for all lookups.

Actually, that entire area is in flux, I still do not know the
fate of the rtcache even without the flow cache :)

   > How about working on making the xfrm layer more lean instead? :)
   
   My last proposal for this (using hlists in the hash tables) was 
   rejected, so I don't see much chance to do this.

Because hlists cannot retain the behavior we need, specifically
because we need the ability to add to the tail.

If it's some in-kernel-image table, why not dynamically allocate the
table in question?
