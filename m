From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix array overrun in bcm43xx_geo_init
Date: Thu, 11 May 2006 10:29:11 +0200
Message-ID: <200605111029.12540.mb@bu3sch.de>
References: <200605051723.51609.mb@bu3sch.de> <20060510204200.43ed67fb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, st3@riseup.net,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:972
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1030183AbWEKIVs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 May 2006 04:21:48 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060510204200.43ed67fb.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11 May 2006 05:42, you wrote:
> Michael Buesch <mb@bu3sch.de> wrote:
> >
> > The problem here is that the bcm34xx driver and the ieee80211
> > stack do not agree on what channels are possible for 802.11a.
> > The ieee80211 stack only wants channels between 34 and 165, while
> > the bcm43xx driver accepts anything from 0 to 200. I made the
> > bcm43xx driver comply with the ieee80211 stack expectations, by
> > using the proper constants.
> > 
> > Signed-off-by: Jean Delvare <jdelvare@suse.de>
> > 
> > [mb]: Reduce stack usage by kzalloc-ing ieee80211_geo
> > 
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> I find this changelog confusing.  We seem to have two patches, one written
> by Jean and one by yourself, perhaps?  And the fact that the changlog
> didn't start with

I simply added one or two lines of code.

> From: Jean Delvare <jdelvare@suse.de>
> 
> indicates that you are to be considered the primary author?

No, I forgot about that line.

> btw, we seem to have a number of bcm43xx patches banking up.  I don't know
> if John has merged them because we're back in the situation where some of
> John's tree has been merged into Jeff's tree but hasn't gone upstream - so
> my git-wireless.patch generates a massive reject storm against git-netdev.patch
> 
> So I suspect that all these bcm43xx might not be making it into 2.6.17.

I think most of the patches should already be merged by john. But I did not
recheck this. It would be bad, if they won't make it for 2.6.17, though,
as they are all heavy bugfixes that prevent hard oopses for people
with special cards, that the developers did not have.

-- 
Greetings Michael.
