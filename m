From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: fix gcc -Wconversion warning
Date: Mon, 12 Oct 2015 19:41:08 -0700 (PDT)
Message-ID: <20151012.194108.1906379614006694718.davem@davemloft.net>
References: <1444412147-21589-1-git-send-email-ronen.arad@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932196AbbJMCZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 22:25:08 -0400
In-Reply-To: <1444412147-21589-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ronen Arad <ronen.arad@intel.com>
Date: Fri,  9 Oct 2015 10:35:47 -0700

> RTA_ALIGNTO is currently define as 4. It has to be 4U to prevent warning
> for RTA_ALIGN and RTA_DATA expansions when -Wconversion gcc option is
> enabled.
> This follows NLMSG_ALIGNTO definition in <include/uapi/linux/netlink.h>.
> 
> Signed-off-by: Ronen Arad <ronen.arad@intel.com>

Applied, thank you.
