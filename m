From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC patch (against wireless-next)] include/net/cfg80211.h:
 wiphy_<level> messages use dev_printk
Date: Wed, 25 Aug 2010 20:25:36 +0200
Message-ID: <1282760736.3667.9.camel@jlt3.sipsolutions.net>
References: <1282245848.6724.261.camel@Joe-Laptop>
	 <1282246784.4507.14.camel@jlt3.sipsolutions.net>
	 <1282342439.1960.84.camel@Joe-Laptop> <20100825180129.GK2557@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, linux-wireless@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:37261 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab0HYSZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 14:25:43 -0400
In-Reply-To: <20100825180129.GK2557@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-25 at 14:01 -0400, John W. Linville wrote:

> > "<level>dev_driver_string(&wiphy->dev) dev_name(&wiphy->dev): wiphy_name(wiphy): " fmt, ##args
> > 
> > for instance:
> > 
> > [   41.261941] ieee80211 phy0: phy0: Selected rate control algorithm 'minstrel_ht'
> > 
> > ie: redundant.
> > wiphy_name(wiphy) is an inline for dev_name(&wiphy->dev)
> > 
> > So it's appropriate to use:
> > 
> > #define wiphy_<level>(wiphy, fmt, arg...) dev_<level>(&wiphy->dev, fmt, ##arg) 
> > 
> > and the output becomes:
> > 
> > [   41.261941] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Everyone OK w/ this version?

I don't care much :)

johannes


