From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATH] Allow mtu bigger than 1500 for ieee80211
Date: Fri, 29 Sep 2006 11:30:50 +0200
Message-ID: <20060929093050.GA19115@zlug.org>
References: <451C0D05.4050705@free.fr> <1159515501.2644.3.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: matthieu castet <castet.matthieu@free.fr>, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:23366 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1751361AbWI2Jaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 05:30:55 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1159515501.2644.3.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2006 at 09:38:21AM +0200, Johannes Berg wrote:
> On Thu, 2006-09-28 at 19:57 +0200, matthieu castet wrote:
> 
> > +	if ((new_mtu < 68) || (new_mtu > IEEE80211_DATA_LEN))
> > +		return -EINVAL;
> 
> What's with that lower limit, why 68?

Isn't 68 the minimum MTU required by IPv4?
