From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Sat, 12 Aug 2006 14:51:19 +0400
Message-ID: <20060812105119.GA378@2ka.mipt.ru>
References: <20060809054648.GD17446@2ka.mipt.ru> <1155127040.12225.25.camel@twins> <20060809130752.GA17953@2ka.mipt.ru> <1155130353.12225.53.camel@twins> <44DD4E3A.4040000@redhat.com> <20060812084713.GA29523@2ka.mipt.ru> <1155374390.13508.15.camel@lappy> <20060812093706.GA13554@2ka.mipt.ru> <1155377887.13508.27.camel@lappy> <20060812104224.GA12353@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60876 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S964823AbWHLKwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2006 06:52:05 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <20060812104224.GA12353@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 12, 2006 at 02:42:26PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > Hence the alternative allocator to use on tight memory conditions.
> 
> If transferred to your implementation, then just steal some pages from
> SLAB when new network device is added and use them when OOM happens.
> It is much simpler and can help in the most of situations.

And just to make things clear - I do not insult your implementation 
in any way, it can be 100% correct and behave perfectly.
I'm just saying that there are other methods to solve the problem which
seems to me more appropriate.

-- 
	Evgeniy Polyakov
