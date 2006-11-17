From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: d80211: clean up some list and loop code
Date: Thu, 16 Nov 2006 19:00:02 -0500
Message-ID: <20061116234148.GB3297@tuxdriver.com>
References: <1163718270.3392.19.camel@johannes.berg> <20061116232455.GA3297@tuxdriver.com> <1163720260.3392.24.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:26379 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1424609AbWKQABL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 19:01:11 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1163720260.3392.24.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 17, 2006 at 12:37:40AM +0100, Johannes Berg wrote:

> > FWIW, I think I prefer the "for (;;)" version for endless loops.
> > It looks more intentional to me.  Some grep'ing showed nearly equal
> > usage of "for (;;)" versus "while (1)".  Is there any "official"
> > preference?  I don't see anything in CodingStyle about it.
> 
> I think while (1) looks more intentional, but I suppose that's because I
> grew up with pascal where you can't do all these weird things with for
> loops.
> 
> Feel free to drop this part of the patch if you wish, or, if you want, I
> can resend without that too :)

No need to resend.  Any other opinions on this?  I suppose it is just
a beached discussion...

-- 
John W. Linville
linville@tuxdriver.com
