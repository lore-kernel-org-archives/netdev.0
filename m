From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] bridge: allow adding of fdb entries
 pointing to the bridge device
Date: Mon, 12 Oct 2015 05:12:52 -0700 (PDT)
Message-ID: <20151012.051252.617752883924274108.davem@davemloft.net>
References: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, nikolay@cumulusnetworks.com,
	netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36068 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751426AbbJLL5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 07:57:01 -0400
In-Reply-To: <1444325932-1577-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu,  8 Oct 2015 10:38:52 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch enables adding of fdb entries pointing to the bridge device.
> This can be used to propagate mac address of vlan interfaces
> configured on top of the vlan filtering bridge.
> 
> Before:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
> RTNETLINK answers: Invalid argument
> 
> After:
> $bridge fdb add 44:38:39:00:27:9f dev bridge
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v1 - v2 : fix kbuild warnings
> v2 - v3 : address review comments from Nikolay (use of br_vlan_should_use)

Applied, thanks.
