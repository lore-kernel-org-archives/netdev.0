From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2 2/5] rtnl/ipv6: use netconf msg to
 advertise forwarding status
Date: Fri, 26 Oct 2012 02:18:30 -0400 (EDT)
Message-ID: <20121026.021830.1470799532580844849.davem@davemloft.net>
References: <20121023.132940.1732325493436273627.davem@davemloft.net>
	<1351094579-3911-1-git-send-email-nicolas.dichtel@6wind.com>
	<1351094579-3911-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43825 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756412Ab2JZGSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 02:18:31 -0400
In-Reply-To: <1351094579-3911-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 24 Oct 2012 18:02:56 +0200

> +static inline int inet6_netconf_msgsize_devconf(int type)

Outside of header files, we don't add explicit inlines, we let
the compiler decide.
