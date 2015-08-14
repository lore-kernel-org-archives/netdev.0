From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] net: track link status of ipv6 nexthops
Date: Thu, 13 Aug 2015 21:27:42 -0700 (PDT)
Message-ID: <20150813.212742.327559797898002082.davem@davemloft.net>
References: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ddutt@cumulusnetworks.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbHNE1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:27:43 -0400
In-Reply-To: <1439476741-952-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Thu, 13 Aug 2015 10:39:00 -0400

> Add support to track current link status of ipv6 nexthops to match
> recent changes that added support for ipv4 nexthops.  This takes a
> simple approach to track linkdown status for next-hops and simply
> checks the dev for the dst entry and sets proper flags that to be used
> in the netlink message.
> 
> v2: drop use of rt6i_nhflags since it is not needed right now
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>

Applied.
