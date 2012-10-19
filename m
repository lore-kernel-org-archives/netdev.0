From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [stable 2.6.32.y PATCH 0/6] net: fixes for cached dsts are never invalidated
Date: Fri, 19 Oct 2012 16:22:44 -0400
Message-ID: <20121019202244.GH8315@kvack.org>
References: <20121019195557.GG17417@1wt.eu> <20121019.160104.115897882147794932.davem@davemloft.net> <20121019200318.GH17417@1wt.eu> <20121019.160711.1159467896676133280.davem@davemloft.net> <20121019201430.GI17417@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:44532 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754399Ab2JSUWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 16:22:44 -0400
Content-Disposition: inline
In-Reply-To: <20121019201430.GI17417@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 19, 2012 at 10:14:31PM +0200, Willy Tarreau wrote:
...
> So maybe in the end we should just merge d11a4dc18 that Ben found to be
> the least invasive one fixing the issues, and we'd be in sync with the
> rest of the stable branches, even if, as you noted a few days ago, it's
> only a partial fix for the issue.
> 
> Ben, what's your opinion on this ? I know it's never fun to do backports
> and not merge them later, but I trust David more than anyone else on the
> network part, so if he decided that while incomplete, the patch above
> was all that was needed for other stable branches, maybe we should just
> stay on the safe side and do the same ?

There is a caveat to the minimally invasive fix: doing so will result in 
cached routes always being lookup up when the check occurs.  This could 
potentially result in a performance regression from some users.  The 
tradeoffs here are really murky.

		-ben
-- 
"Thought is the essence of where you are now."
