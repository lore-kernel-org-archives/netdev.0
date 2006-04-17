From: "David S. Miller" <davem@davemloft.net>
Subject: Re: skb diet
Date: Sun, 16 Apr 2006 22:25:51 -0700 (PDT)
Message-ID: <20060416.222551.46522402.davem@davemloft.net>
References: <200604152122.01914.ak@suse.de>
	<baebb9a00604160556o2abe6df1y4a185a0fd8f45e7b@mail.gmail.com>
	<200604161716.31276.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkotry@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:2505
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750705AbWDQFZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 01:25:28 -0400
To: ak@suse.de
In-Reply-To: <200604161716.31276.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sun, 16 Apr 2006 17:16:31 +0200

> On Sunday 16 April 2006 14:56, Hisham Kotry wrote:
> > > Linux 2.0 did something like this, but that was removed for good
> > > reasons. Now TCP always clones skbs before sending it out.
> >
> > Do you remember what those reasons were? I couldn't find a related
> > discussion in the archives. I think the BSD mbuf tags approach is
> > sound enough to justify the move.
> 
> From your description so far it seems to only have disadvantages.

I totally agree, tags are very stupid.

I only brought them up long as food-for-thought, not as a very
serious candidate for implementation.

Indirection is a performance killer, and we've seen this time and
time again in the past.  Tags add more indirection for questionable
gains.
