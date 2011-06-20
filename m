From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFT PATCH 3/9] net: ethtool: break association of ETH_FLAG_*
 with NETIF_F_*
Date: Mon, 20 Jun 2011 22:30:57 +0100
Message-ID: <1308605457.2701.197.camel@bwh-desktop>
References: <51d2fd4cf6855c2285ca9bcd8d267abedcbc599c.1308596963.git.mirq-linux@rere.qmqm.pl>
	 <1308600681.2701.159.camel@bwh-desktop>
	 <20110620135109.63d81d83@nehalam.ftrdhcpuser.net>
	 <20110620.135224.1609394919600206157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34670 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab1FTVbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:31:00 -0400
In-Reply-To: <20110620.135224.1609394919600206157.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-20 at 13:52 -0700, David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, 20 Jun 2011 13:51:09 -0700
> 
> > I have no problem with dropping or changing the sysfs feature output.
> > It is useful to have a way to check if device supports something.
> 
> These days that's not even where we store the "capabilities" of the
> device.
> 
> That happens in ->hw_features now.

In fact there never used to be any way for user-space to find out which
capabilities were *supported*, other than to try enabling them.

Once we work out how to deal with kernel-named features in ethtool it
shouldn't be too hard to add options to (quietly) test whether a given
feature is supported or enabled.  Having done that, we could think about
a fallback to sysfs and knowledge of the bit definitions for older
kernel versions.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

