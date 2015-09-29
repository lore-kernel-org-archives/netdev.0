From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Add HW timesptamp support for RX
Date: Mon, 28 Sep 2015 22:35:47 -0700 (PDT)
Message-ID: <20150928.223547.2994487490205218.davem@davemloft.net>
References: <1443416213-18952-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54001 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbI2Ffs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:35:48 -0400
In-Reply-To: <1443416213-18952-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Mon, 28 Sep 2015 10:26:53 +0530

> Adds support for ethtool get time stamp ioctl, which is used by
> tcpdump to get the supported time stamp types
> 
> eg: tcpdump -i eth5 -J
> Time stamp types for eth5 (use option -j to set):
>   host (Host)
>   adapter_unsynced (Adapter, not synced with system time)
> 
> Adds support for adapter unsynced mode, by adding SIOCSHWTSTAMP support
> in driver. 
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
