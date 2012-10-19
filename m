From: Willy Tarreau <w@1wt.eu>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 21:48:22 +0200
Message-ID: <20121019194822.GF17417@1wt.eu>
References: <20121019191347.GD13515@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33803 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758009Ab2JSTsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 15:48:31 -0400
Content-Disposition: inline
In-Reply-To: <20121019191347.GD13515@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Fri, Oct 19, 2012 at 03:13:48PM -0400, Benjamin LaHaise wrote:
> This is v2 of an attempt to pull in the relevant fixes for a problem in
> v2.6.32 kernels where invalid cached routes are retained even after changes
> to the routing table have been made.  A simple test case can be found at 
> http://marc.info/?l=linux-netdev&m=135015076708950&w=2 .  Based on feedback 
> from David Miller, additional changes have been pulled in, including fixes
> for the same issue in IPv6.  Most of the patches required some rework owing
> to the large differences in the networking stack between 2.6.32 and 3.6.
> 
> I have performed basic tests to confirm that the cases I was hitting are
> now fixed, including a couple of tests with IPv4 and IPv6.  Comments?  
> Thanks again to David for the pointers to the additional fixes required in
> this area.

Looks like you've done an amazing work. I'm not the best person to judge
if these changes are valid or not, so I'll trust you and David on this.

I just have two questions: since you had to backport them from 3.6 to 2.6.32,
I'm assuming that the equivalent was not ready in closer LTS kernels (2.6.34,
3.0, 3.2, 3.4). Does this mean they're affected by the same issue too or are
they immune ? And if they're affected, are you going to proceed with forward
porting of your work for the closest ones (.34 and 3.0 come to mind) ? And if
they aren't affected, do you think that picking some changes there would have
been easier ?

As you probably know, we want to ensure that people who upgrade from an old
LTS to a newer one won't experience regressions due to problems which were
fixed only in the older version.

Thanks !
Willy
