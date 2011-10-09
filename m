From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] truesize lies
Date: Sun, 09 Oct 2011 12:25:09 -0700
Message-ID: <m2wrce0xyi.fsf@firstfloor.org>
References: <1318186948.5276.49.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22708 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752017Ab1JITZJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Oct 2011 15:25:09 -0400
In-Reply-To: <1318186948.5276.49.camel@edumazet-laptop> (Eric Dumazet's
	message of "Sun, 09 Oct 2011 21:02:28 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> After some analysis, I found full sized tcp skbs (len=1440) had a 2864
> bytes truesize on my wifi adapter. Ouch...

It's probably more like 4096. slab rounds to powers of two.

> What should we do exactly ?

Give up? It's always been a lie.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
