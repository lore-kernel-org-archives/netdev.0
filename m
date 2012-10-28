From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/5] Allow to monitor protocol configuration
Date: Sun, 28 Oct 2012 19:05:41 -0400 (EDT)
Message-ID: <20121028.190541.1706890905787524632.davem@davemloft.net>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
	<1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43853 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094Ab2J1XFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 19:05:43 -0400
In-Reply-To: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 26 Oct 2012 10:28:48 +0200

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
> v3: remove inline attribute in non header files
> 
> v2: rename functions to be consistent
>     specify type of the attribute to notify when calling
>     inet[6]_netconf_notify_devconf(), goal is to notify only thinks that
>     changed.
>     add RTM_GETNETCONF support
> 
> Comments are welcome.

All applied, thanks Nicolas.
