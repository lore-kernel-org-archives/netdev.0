From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: ethernet: add driver for Aurora VLSI
 NB8800 Ethernet controller
Date: Sat, 24 Oct 2015 07:24:05 -0700 (PDT)
Message-ID: <20151024.072405.1054520777247556344.davem@davemloft.net>
References: <1445531330-17461-1-git-send-email-mans@mansr.com>
	<1445531330-17461-2-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mans@mansr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbbJXOHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 10:07:32 -0400
In-Reply-To: <1445531330-17461-2-git-send-email-mans@mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mans Rullgard <mans@mansr.com>
Date: Thu, 22 Oct 2015 17:28:50 +0100

> +static void nb8800_mac_tx(struct net_device *dev, int enable)
 ...
> +static void nb8800_mac_rx(struct net_device *dev, int enable)
 ...
> +static void nb8800_mac_af(struct net_device *dev, int enable)

Please use 'bool' and true/false for 'enable'.

> +static int nb8800_alloc_rx(struct net_device *dev, int i, int napi)

Likewise here for 'napi'.
