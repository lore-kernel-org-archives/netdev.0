From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: fix mpls_net_init memory leak
Date: Mon, 31 Aug 2015 12:45:41 -0700 (PDT)
Message-ID: <20150831.124541.1915347223923733397.davem@davemloft.net>
References: <1441043059-11984-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51523 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425AbbHaTpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:45:42 -0400
In-Reply-To: <1441043059-11984-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Mon, 31 Aug 2015 10:44:19 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Fix a memory leak in the mpls netns init function in case of failure. If
> register_net_sysctl fails then we need to free the ctl_table.
> 
> Fixes: 7720c01f3f59 ("mpls: Add a sysctl to control the size of the mpls label table")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Applied, thank you.
