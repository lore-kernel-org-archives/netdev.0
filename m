From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 01/14] tipc: add bearer disable/enable to new
 netlink api
Date: Fri, 12 Sep 2014 17:07:25 -0400 (EDT)
Message-ID: <20140912.170725.299787405870396006.davem@davemloft.net>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
	<1410424167-17427-2-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51052 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbaILVH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:07:27 -0400
In-Reply-To: <1410424167-17427-2-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <richard.alpe@ericsson.com>
Date: Thu, 11 Sep 2014 10:29:14 +0200

> +struct tipc_nl_msg {
> +	struct sk_buff *skb;
> +	u32 portid;
> +	u32 seq;
> +};

This datastructure has no users this early in the patch series.  Add it to the
patch which actually has a user.
