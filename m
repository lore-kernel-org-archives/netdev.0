From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] bcm43xx: Fix array overrun in bcm43xx_geo_init
Date: Wed, 10 May 2006 20:42:00 -0700
Message-ID: <20060510204200.43ed67fb.akpm@osdl.org>
References: <200605051723.51609.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, st3@riseup.net,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17632 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965078AbWEKDpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 23:45:09 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200605051723.51609.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> wrote:
>
> The problem here is that the bcm34xx driver and the ieee80211
> stack do not agree on what channels are possible for 802.11a.
> The ieee80211 stack only wants channels between 34 and 165, while
> the bcm43xx driver accepts anything from 0 to 200. I made the
> bcm43xx driver comply with the ieee80211 stack expectations, by
> using the proper constants.
> 
> Signed-off-by: Jean Delvare <jdelvare@suse.de>
> 
> [mb]: Reduce stack usage by kzalloc-ing ieee80211_geo
> 
> Signed-off-by: Michael Buesch <mb@bu3sch.de>

I find this changelog confusing.  We seem to have two patches, one written
by Jean and one by yourself, perhaps?  And the fact that the changlog
didn't start with

From: Jean Delvare <jdelvare@suse.de>

indicates that you are to be considered the primary author?


btw, we seem to have a number of bcm43xx patches banking up.  I don't know
if John has merged them because we're back in the situation where some of
John's tree has been merged into Jeff's tree but hasn't gone upstream - so
my git-wireless.patch generates a massive reject storm against git-netdev.patch

So I suspect that all these bcm43xx might not be making it into 2.6.17.
