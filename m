From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] net: make dev_disable_lro use physical device if
 passed a vlan dev (v2)
Date: Sat, 28 May 2011 04:11:03 +0100
Message-ID: <1306552263.2759.57.camel@bwh-desktop>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
	 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
	 <1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:19650 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402Ab1E1DLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 23:11:07 -0400
In-Reply-To: <1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-24 at 14:31 -0400, Neil Horman wrote:
> If the device passed into dev_disable_lro is a vlan, then repoint the dev
> poniter so that we actually modify the underlying physical device.
[...]

Thanks Neil, this looks good.

There seems to be a slightly weird bug remaining, in that NETIF_F_LRO
may remain set on the VLAN device.  But that's really cosmetic and
should go away in 2.6.40 along with the old ethtool operations for
offload setting.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

