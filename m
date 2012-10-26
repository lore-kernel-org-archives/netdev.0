From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2 0/5] Allow to monitor protocol
 configuration
Date: Fri, 26 Oct 2012 02:19:26 -0400 (EDT)
Message-ID: <20121026.021926.1234251415536174852.davem@davemloft.net>
References: <20121023.132940.1732325493436273627.davem@davemloft.net>
	<1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab2JZGT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 02:19:27 -0400
In-Reply-To: <1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 24 Oct 2012 18:02:54 +0200

> This patch serie aims to advertising via netlink any change in the network
> configuration of a protocol (network or transport). For example the announcement
> when ip forwarding parameter is toggled. 
> 
> It adds a new kind of messages, RTM_NEWNETCONF/RTM_GETNETCONF.
> 
> The patch which adds the support of netconf messages in iproute2 will be sent
> when the feature will be included.  If someone is interested to get it before,
> just tell me!
> 
> v2: rename functions to be consistent
>     specify type of the attribute to notify when calling
>     inet[6]_netconf_notify_devconf(), goal is to notify only thinks that
>     changed.
>     add RTM_GETNETCONF support
> 
> Comments are welcome.

Besides the inline function thing, this set looks fine to me.
