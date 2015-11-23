From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: ipmr, ip6mr: fix static leaks on netns
 destruction
Date: Mon, 23 Nov 2015 12:14:52 -0500 (EST)
Message-ID: <20151123.121452.1702874418203510728.davem@davemloft.net>
References: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbbKWROy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:14:54 -0500
In-Reply-To: <1448024060-20466-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 20 Nov 2015 13:54:18 +0100

> While testing various ipmr scenarios I found that static mfc entries and
> static devices get leaked on netns/table destruction because
> mroute_clean_tables doesn't delete them. It is fine to leave the static
> entries when cleaning up the mrtsock, but when destroying the table they
> need to be removed.

Series applied.
