From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/irda/: proper prototypes
Date: Tue, 02 Jan 2007 00:39:53 -0800 (PST)
Message-ID: <20070102.003953.21925510.davem@davemloft.net>
References: <20061218034626.GY10316@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51111
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932985AbXABIjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jan 2007 03:39:54 -0500
To: bunk@stusta.de
In-Reply-To: <20061218034626.GY10316@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Mon, 18 Dec 2006 04:46:26 +0100

> This patch adds proper prototypes for some functions in
> include/net/irda/irda.h
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
 ...
> +struct net_device;
> +struct packet_type;
> +
> +void irda_proc_register(void);
> +void irda_proc_unregister(void);
> +
> +int irda_sysctl_register(void);
> +void irda_sysctl_unregister(void);
> +
> +int irsock_init(void);
> +void irsock_cleanup(void);
> +
> +int irlap_driver_rcv(struct sk_buff *skb, struct net_device *dev,
> +		     struct packet_type *ptype, struct net_device *orig_dev);

Remind me why you remove the "extern" from "external" function
declarations all the time?

I don't like it, even if it's "correct", because it is inconsistent
with what we do in the entire rest of the networking code.
