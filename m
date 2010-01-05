From: David Miller <davem@davemloft.net>
Subject: Re: [RFC-PATCH] libiscsi dhcp handler
Date: Mon, 04 Jan 2010 22:42:18 -0800 (PST)
Message-ID: <20100104.224218.35346973.davem@davemloft.net>
References: <4B014F95.8000906@chelsio.com>
	<20091116.051835.125328285.davem@davemloft.net>
	<4B01577E.2020003@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michaelc@cs.wisc.edu, open-iscsi@googlegroups.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James.Bottomley@suse.de, kxie@chelsio.com
To: rakesh@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48564
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753095Ab0AEGmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 01:42:15 -0500
In-Reply-To: <4B01577E.2020003@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rakesh Ranjan <rakesh@chelsio.com>
Date: Mon, 16 Nov 2009 19:15:34 +0530

> +	/* Construct UDP header */
> +	udph = &pkt->udph;
> +	udph->source = htons(DHCPC_CLIENT_PORT);
> +	udph->dest = htons(DHCPC_SERVER_PORT);
> +	udph->len = htons(sizeof(struct dhcp_pkt) - sizeof(struct iphdr));

UDP checksum is not set, and is also not validated on receive.
