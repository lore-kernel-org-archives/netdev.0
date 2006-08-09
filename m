From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH 1/8] d80211/bcm43xx: Modify struct ieee80211_rx_status for wireless statistics.
Date: Wed, 9 Aug 2006 13:34:33 -0700
Message-ID: <20060809203433.GM26616@instant802.com>
References: <44D92535.8090303@lwfinger.net> <1155133346.3615.1.camel@localhost.localdomain> <44D9FD6C.9030006@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-17.dex002.intermedia.net ([64.78.21.83]:4280 "EHLO
	dhost002-17.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751315AbWHIUg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 16:36:27 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <44D9FD6C.9030006@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:21:16AM -0500, Larry Finger wrote:
> Dan Williams wrote:
> >>          int ssi;
> >>+	int maxssi;

> >Spacing?  Looks like you're using real tabs here, but the current code
> >uses 8 spaces instead.  Not sure if that's a problem.
> 
> I am using tabs, which I think is the preferred way. I also remember that 
> the rule is not to change the white space on things you are not touching. 
> Is that correct?

That's at least the way I would prefer to do this. Unrelated whitespace
changes as part of a patch are almost always bad and large patch of
modifying just the whitespaces around the tree is likely to add large
number of conflicts for pending work that goes on at the moment. 

Unfortunately, I forgot to replace this part when making the initial
release of the Devicescape stack. I've always used tabs myself, but some
of the areas of the code that I did not write was done using spaces.
Anyway, this should move to using tabs over time whenever source code is
being modified.

-- 
Jouni Malinen                                            PGP id EFC895FA
