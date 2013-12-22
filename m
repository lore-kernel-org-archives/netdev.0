From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net: vxlan: use custom ndo_change_mtu
 handler
Date: Sun, 22 Dec 2013 18:01:47 -0500 (EST)
Message-ID: <20131222.180147.846554998278875374.davem@davemloft.net>
References: <1387322468-17368-1-git-send-email-dborkman@redhat.com>
	<20131217154052.6e641cf2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756087Ab3LVXBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:01:48 -0500
In-Reply-To: <20131217154052.6e641cf2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 17 Dec 2013 15:40:52 -0800

> P.s: I wonder if notifier handler would be good to handle changes
> to underlying device MTU on the fly.

I think it would be a good idea.
