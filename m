From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Mon, 16 Jul 2007 14:02:47 +0200
Message-ID: <20070716120247.GG5195@kernel.dk>
References: <Line.LNX.4.64.0707121608100.10773@d.namei> <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk> <1184575545.15112.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:22009 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754862AbXGPMDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 08:03:30 -0400
Content-Disposition: inline
In-Reply-To: <1184575545.15112.0.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 16 2007, Johannes Berg wrote:
> On Fri, 2007-07-13 at 13:05 +0200, Jens Axboe wrote:
> > On Fri, Jul 13 2007, Johannes Berg wrote:
> > > On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> > > > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > > > following as a possible cause:
> > > 
> > > I'm also seeing stalls with synergy.
> > 
> > Please try the below.
> 
> I usually see stalls sending data from machine A to machine B. I just
> upgraded machine B to commit 8d9107e8c50e1c4ff43c91c8841805833f3ecfb9
> (Fri Jul 13 16:53:18 2007 -0700) and the tree includes this patch. This
> did not, however, fix the problem so I guess the problem is on the
> sender side. Due to wireless-dev lagging behind I there still have
> 2.6.22-something where this patch doesn't apply. I hope John will merge
> again soon and then I'll report back whether I still see the stalling
> behaviour with a current tree that includes this patch.

Yep, it's a sender thing, so upgrading the receiver will not change
anything.

-- 
Jens Axboe

