From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 38032] New: default values of
 /proc/sys/net/ipv4/udp_mem does not consider huge page allocation
Date: Thu, 07 Jul 2011 00:27:17 -0700 (PDT)
Message-ID: <20110707.002717.1495810845761908702.davem@davemloft.net>
References: <6.2.5.6.2.20110706212254.05bff4c8@binnacle.cx>
	<1310011173.2481.20.camel@edumazet-laptop>
	<1310013490.2481.35.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: starlight@binnacle.cx, akpm@linux-foundation.org, linux-mm@kvack.org,
        netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
        aquini@linux.com
To: eric.dumazet@gmail.com
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1310013490.2481.35.camel@edumazet-laptop>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jul 2011 06:38:10 +0200

> [PATCH] net: refine {udp|tcp|sctp}_mem limits
> 
> Current tcp/udp/sctp global memory limits are not taking into account
> hugepages allocations, and allow 50% of ram to be used by buffers of a
> single protocol [ not counting space used by sockets / inodes ...]
> 
> Lets use nr_free_buffer_pages() and allow a default of 1/8 of kernel ram
> per protocol, and a minimum of 128 pages.
> Heavy duty machines sysadmins probably need to tweak limits anyway.
> 
> 
> References: https://bugzilla.stlinux.com/show_bug.cgi?id=38032
> Reported-by: starlight <starlight@binnacle.cx>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
