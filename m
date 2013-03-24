From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] ipv4: provide addr and netconf dump
 consistency info
Date: Sun, 24 Mar 2013 17:16:53 -0400 (EDT)
Message-ID: <20130324.171653.1210930844712331473.davem@davemloft.net>
References: <514C8559.5030301@6wind.com>
	<1363969723-4390-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, junwei.zhang@6wind.com,
	hongjun.li@6wind.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43843 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab3CXVQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:16:55 -0400
In-Reply-To: <1363969723-4390-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 22 Mar 2013 17:28:42 +0100

> This patch takes benefit of dev_addr_genid and dev_base_seq to check if a change
> occurs during a netlink dump. If a change is detected, the flag NLM_F_DUMP_INTR
> is set in the first message after the dump was interrupted.
> 
> Note that seq and prev_seq must be reset between each family in rtnl_dump_all()
> because they are specific to each family.
> 
> Reported-by: Junwei Zhang <junwei.zhang@6wind.com>
> Reported-by: Hongjun Li <hongjun.li@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
