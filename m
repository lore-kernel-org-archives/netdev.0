From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] packet: uses kfree_skb() for errors.
Date: Thu, 14 Apr 2016 17:53:26 -0400 (EDT)
Message-ID: <20160414.175326.1930035534571762555.davem@davemloft.net>
References: <1460668204-27112-1-git-send-email-weongyo.linux@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: weongyo.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751500AbcDNVx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 17:53:28 -0400
In-Reply-To: <1460668204-27112-1-git-send-email-weongyo.linux@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weongyo Jeong <weongyo.linux@gmail.com>
Date: Thu, 14 Apr 2016 14:10:04 -0700

> consume_skb() isn't for error cases that kfree_skb() is more proper
> one.  At this patch, it fixed tpacket_rcv() and packet_rcv() to be
> consistent for error or non-error cases letting perf trace its event
> properly.
> 
> Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>

Applied, thanks.
