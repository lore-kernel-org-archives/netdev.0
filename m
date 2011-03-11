From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 21:17:54 +0000
Message-ID: <1299878274.2814.8.camel@bwh-desktop>
References: <20110310.155556.48513201.davem@davemloft.net>
	 <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
	 <20110311204823.GB7906@fieldses.org>
	 <20110311.130128.71121155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: bfields@fieldses.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:6851 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302Ab1CKVR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 16:17:57 -0500
In-Reply-To: <20110311.130128.71121155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-03-11 at 13:01 -0800, David Miller wrote:
> From: "J. Bruce Fields" <bfields@fieldses.org>
> Date: Fri, 11 Mar 2011 15:48:23 -0500
> 
> > As with the above, it'd make the history a little more self-documenting.
> 
> Once there is even one single commit after the buggy one, this is
> simply impossible since the hashes of subsequent commits depend upon
> the precise contents of the original one.

I think Bruce is suggesting that the fix is committed on a branch from
the broken commit, then merged into whatever branches need it.  I'm not
sure how much that helps, though.  The merge could then involve forward-
porting (as opposed to the current situation where fixes are cherry-
picked and possibly back-ported).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

