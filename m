From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 0/4] return offloaded stats as default and
 expose original sw start
Date: Thu, 12 May 2016 16:36:45 +0200
Message-ID: <20160512143645.GE26864@lunn.ch>
References: <1463047198-10630-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nogahf@mellanox.com,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, linville@tuxdriver.com, tgraf@suug.ch,
	gospo@cumulusnetworks.com, sfeldma@gmail.com, sd@queasysnail.net,
	eranbe@mellanox.com, ast@plumgrid.com, edumazet@google.com,
	hannes@stressinduktion.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36898 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751381AbcELOgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2016 10:36:52 -0400
Content-Disposition: inline
In-Reply-To: <1463047198-10630-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2016 at 11:59:54AM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Until now we had stats functions return SW statistics. However, it makes
> a lot of sense to return HW stats as default.

Hi Jiri

DSA has always returned the HW stats, i.e, ethtool -S shows the
counters the switch has for the port.

How do you expect ethtool to handle your change? ethtool -S will print
both sets? Or are you thinking of adding a new flag?

I'm just trying to understand the big picture, and how it affects DSA,
if at all.

   Andrew
