From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix a potential use after free in fou.c
Date: Fri, 17 Oct 2014 23:46:24 -0400 (EDT)
Message-ID: <20141017.234624.2128135369532839014.davem@davemloft.net>
References: <1413536027-15700-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaJRDq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 23:46:26 -0400
In-Reply-To: <1413536027-15700-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri, 17 Oct 2014 16:53:47 +0800

> From: Li RongQing <roy.qing.li@gmail.com>
> 
> pskb_may_pull() maybe change skb->data and make uh pointer oboslete,
> so reload uh and guehdr
> 
> Fixes: 37dd0247 ("gue: Receive side for Generic UDP Encapsulation")
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Applied.
