From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] snmp: fix some left over of snmp stats
Date: Wed, 14 May 2014 15:34:36 -0400 (EDT)
Message-ID: <20140514.153436.2150741508695034151.davem@davemloft.net>
References: <1399938722-809-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbaENTei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:34:38 -0400
In-Reply-To: <1399938722-809-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 12 May 2014 16:52:02 -0700

> Fengguang reported the following sparse warning:
> 
>>> net/ipv6/proc.c:198:41: sparse: incorrect type in argument 1 (different address spaces)
>    net/ipv6/proc.c:198:41:    expected void [noderef] <asn:3>*mib
>    net/ipv6/proc.c:198:41:    got void [noderef] <asn:3>**pcpumib
> 
> Fixes: commit 698365fa1874aa7635d51667a3 (net: clean up snmp stats code)
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
