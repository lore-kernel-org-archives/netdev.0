From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: ipmr: more cleanups and mfc netlink
 support
Date: Mon, 30 Nov 2015 15:26:48 -0500 (EST)
Message-ID: <20151130.152648.1009126990020327786.davem@davemloft.net>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34027 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbbK3U0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 15:26:50 -0500
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Thu, 26 Nov 2015 15:23:43 +0100

> This set continues with the minor cleanups in the first 6 patches and
> patch 7 adds the first new feature - MFC manipulation via netlink. It
> registers NEWROUTE/DELROUTE for that purpose and uses the same semantics
> as the already present netlink dump. The only new attribute that is used
> is RTA_PREFSRC to denote an MFC_PROXY entry. Currently the table must
> exist before adding an entry, and new tables can be created only via
> setsockopt, but that will be changed in the future.
> This set was tested with modified iproute2 which supports NEWROUTE/DELROUTE
> for RTNL_FAMILY_IPMR.

Looks great, series applied, thanks!
