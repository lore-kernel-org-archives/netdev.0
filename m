From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 02/02] net/ipv4: VTI support new module for
 ip_vti.
Date: Wed, 27 Jun 2012 18:19:47 -0700 (PDT)
Message-ID: <20120627.181947.1681522664070466028.davem@davemloft.net>
References: <20120628010218.GA4056@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806Ab2F1BTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 21:19:51 -0400
In-Reply-To: <20120628010218.GA4056@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Wed, 27 Jun 2012 18:02:18 -0700

> +static int vti_err(struct sk_buff *skb, u32 info)

In net-next, individual ICMP error handlers must explicitly
handle PMTU messages.

You're does not.
