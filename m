From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] bonding: warn user when 802.3ad speed is unknown
Date: Fri, 9 Jun 2017 16:59:32 +0200
Message-ID: <20170609145932.GG20756@lunn.ch>
References: <20170608164811.GB20216@lunn.ch>
 <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170609142359.GD20756@lunn.ch>
 <fcca67e0-a170-6dd7-dcbb-7a0ecc0453d5@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43387 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751597AbdFIO74 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:59:56 -0400
Content-Disposition: inline
In-Reply-To: <fcca67e0-a170-6dd7-dcbb-7a0ecc0453d5@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I just wonder if this should be rate limited?
> So using net_warn_ratelimited()?
> 
> Displaying this message continuously in the log, even at a low rate, seems not
> the best things to do. The first time seems enough, but it would require more
> code for that. Is it not over-engineering?

Maybe look at the _once functions, dev_warn_once, printk_once.

> The ideal solution would be a BUILD_BUG_ON(), but I don't see how to make that.

Me neither.

   Andrew
