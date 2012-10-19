From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Fri, 19 Oct 2012 13:43:39 -0700
Message-ID: <m27gqmry4k.fsf@firstfloor.org>
References: <507F38D4.102@genband.com>
	<1350540348.26103.1015.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:10530 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932917Ab2JSUno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:43:44 -0400
In-Reply-To: <1350540348.26103.1015.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 18 Oct 2012 08:05:48 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> I see no real problem here.
>
> Its like you cut the cable somewhere in the path.

I had a patch for this a long time ago to speed up recovery.
It was very useful with dial on demand ISDN links or DSL
connections that hang up occasionally to force a new IP.

It was in SUSE kernels for a long time, but never made it 
into mainline

http://www.firstfloor.org/pub/ak/quilt-before-arch-merge/patches/iff-dynamic

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
