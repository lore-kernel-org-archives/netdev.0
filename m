From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH net-2.6] net/ethtool: add multiple queue support to
 {get,set}_ringparams
Date: Sun, 14 Mar 2010 04:21:57 +0000
Message-ID: <1268540517.2664.51.camel@localhost>
References: <20100314014335.GA17208@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	netdev <netdev@vger.kernel.org>
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46576 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756716Ab0CNEWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Mar 2010 23:22:08 -0500
In-Reply-To: <20100314014335.GA17208@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-03-14 at 07:13 +0530, Ajit Khaparde wrote:
> With network devices and hence device drivers supporting
> multiple Tx and Rx rings, currently there is no way for
> ethtool to specify which Tx/Rx ring the user wants to get/set.
> This patch enhances the {get,set}_ringparams by allowing
> the user to specify the Tx/Rx ring id of interest.
> Please review.
[...]

So long as queue selection is done using a hash of the flow parameters,
there is no sense in setting different sizes for different queues.  If
drivers use additional queues that are not selected in this way and
which may require different sizes, that information also needs to be
exposed through ethtool (and perhaps to the networking core).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

