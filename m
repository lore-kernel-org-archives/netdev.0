From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: llc: use correct size for sysctl timeout entries
Date: Sun, 25 Jan 2015 00:23:44 -0800 (PST)
Message-ID: <20150125.002344.882303502800355463.davem@davemloft.net>
References: <1422064020-22080-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, acme@ghostprotocols.net,
	netdev@vger.kernel.org
To: sasha.levin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbAYIXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 03:23:45 -0500
In-Reply-To: <1422064020-22080-1-git-send-email-sasha.levin@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin <sasha.levin@oracle.com>
Date: Fri, 23 Jan 2015 20:47:00 -0500

> The timeout entries are sizeof(int) rather than sizeof(long), which
> means that when they were getting read we'd also leak kernel memory
> to userspace along with the timeout values.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thank you.
