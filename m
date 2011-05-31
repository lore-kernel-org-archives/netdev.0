From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] net: make dev_disable_lro use physical device if
 passed a vlan dev (v2)
Date: Mon, 30 May 2011 20:06:40 -0400
Message-ID: <20110531000640.GA2398@neilslaptop.think-freely.org>
References: <1306257314-3925-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-1-git-send-email-nhorman@tuxdriver.com>
 <1306261869-7276-3-git-send-email-nhorman@tuxdriver.com>
 <1306552263.2759.57.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab1EaAG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2011 20:06:59 -0400
Content-Disposition: inline
In-Reply-To: <1306552263.2759.57.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2011 at 04:11:03AM +0100, Ben Hutchings wrote:
> On Tue, 2011-05-24 at 14:31 -0400, Neil Horman wrote:
> > If the device passed into dev_disable_lro is a vlan, then repoint the dev
> > poniter so that we actually modify the underlying physical device.
> [...]
> 
> Thanks Neil, this looks good.
> 
> There seems to be a slightly weird bug remaining, in that NETIF_F_LRO
> may remain set on the VLAN device.  But that's really cosmetic and
> should go away in 2.6.40 along with the old ethtool operations for
> offload setting.
> 
> Ben.
> 
Copy that, thanks Ben.
Neil

> -- 
> Ben Hutchings, Senior Software Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
> 
> 
