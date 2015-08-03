From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: mdb: add/del entry on all vlans if
 vlan_filter is enabled and vid is 0
Date: Mon, 03 Aug 2015 15:44:07 -0700 (PDT)
Message-ID: <20150803.154407.1641134905324878853.davem@davemloft.net>
References: <1438601356-20885-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, sashok@cumulusnetworks.com,
	nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754572AbbHCWoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 18:44:16 -0400
In-Reply-To: <1438601356-20885-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon,  3 Aug 2015 13:29:16 +0200

> From: Satish Ashok <sashok@cumulusnetworks.com>
> 
> Before this patch when a vid was not specified, the entry was added with
> vid 0 which is useless when vlan_filtering is enabled. This patch makes
> the entry to be added on all configured vlans when vlan filtering is
> enabled and respectively deleted from all, if the entry vid is 0.
> This is also closer to the way fdb works with regard to vid 0 and vlan
> filtering.
 ...
> Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, but as usual if any existing user ends up being broken I will
revert this.

Thanks.
