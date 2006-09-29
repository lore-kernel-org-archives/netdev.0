From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATH] Allow mtu bigger than 1500 for ieee80211
Date: Fri, 29 Sep 2006 13:56:10 +0200
Message-ID: <1159530970.2644.21.camel@ux156>
References: <451C0D05.4050705@free.fr> <1159515501.2644.3.camel@ux156>
	 <20060929093050.GA19115@zlug.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: matthieu castet <castet.matthieu@free.fr>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:3756 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751232AbWI2LzY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 07:55:24 -0400
To: Joerg Roedel <joro-lkml@zlug.org>
In-Reply-To: <20060929093050.GA19115@zlug.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-29 at 11:30 +0200, Joerg Roedel wrote:
> On Fri, Sep 29, 2006 at 09:38:21AM +0200, Johannes Berg wrote:
> > On Thu, 2006-09-28 at 19:57 +0200, matthieu castet wrote:
> > 
> > > +	if ((new_mtu < 68) || (new_mtu > IEEE80211_DATA_LEN))
> > > +		return -EINVAL;
> > 
> > What's with that lower limit, why 68?
> 
> Isn't 68 the minimum MTU required by IPv4?

No idea, but shouldn't there be a named constant somewhere for that
then?

johannes
