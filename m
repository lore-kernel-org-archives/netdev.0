From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] ethtool: Add link down reason callback
Date: Sat, 24 Jun 2017 21:04:35 +0200
Message-ID: <20170624190435.GN4875@lunn.ch>
References: <1498050286-17141-1-git-send-email-galp@mellanox.com>
 <1498050286-17141-2-git-send-email-galp@mellanox.com>
 <20170621135809.GC27585@lunn.ch>
 <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        "John W. Linville" <linville@tuxdriver.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Jiri Pirko <jiri@mellanox.com>,
        David Decotigny <decot@googlers.com>, kernel-team@fb.com
To: Gal Pressman <galp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34006 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751436AbdFXTEl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 24 Jun 2017 15:04:41 -0400
Content-Disposition: inline
In-Reply-To: <8e7ffead-350e-bd7f-c7ea-fe057969d0d3@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 22, 2017 at 11:09:04AM +0300, Gal Pressman wrote:
> 
> >> +enum {
> >> +	ETHTOOL_LINK_VENDOR_SPECIFIC = -1, /* Vendor specific issue provided in vendor_reason */
> >> +	ETHTOOL_LINK_NO_ISSUE, /* No issue observed with link */
> >> +	ETHTOOL_LINK_REASON_UNKNOWN, /* Unknown reason */
> > I think OTHER would be better that UNKNOWN. 
> 
> Fine with me.
> >> +	ETHTOOL_LINK_NETDEV_CARRIER_DOWN, /* Netdev carrier is down */
> >> +	ETHTOOL_LINK_ADMIN_DOWN, /* Admin down */
> > These two are interesting. We have that information already. Why do we
> > want it again?
> 
> My goal is to gather all link issue reasons in one place.

I'm actually wondering if this is a user space problem. Nearly
everything you list is already available. Some you get from ip link,
others from ethtool or ethtool --module-info, including I2C bus
error, since you would expect EIO or ETIMEOUT.

If you were to write a user space tool using the information what is
currently available, what would be missing?

	  Andrew
