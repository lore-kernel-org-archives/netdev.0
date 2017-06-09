From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2] net: ipmr: Fix some mroute forwarding issues in
 vrf's
Date: Fri, 9 Jun 2017 16:28:12 +0200
Message-ID: <20170609142812.GE20756@lunn.ch>
References: <20170609142259.24423-1-sharpd@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        Thomas.Winter@alliedtelesis.co.nz, nikolay@cumulusnetworks.com,
        yotamg@mellanox.com, idosch@mellanox.com, roopa@cumulusnetworks.com
To: Donald Sharp <sharpd@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43331 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdFIO2Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 10:28:16 -0400
Content-Disposition: inline
In-Reply-To: <20170609142259.24423-1-sharpd@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  static void ip_mr_forward(struct net *net, struct mr_table *mrt,
> -			  struct sk_buff *skb, struct mfc_cache *cache,
> -			  int local);
> +			  struct net_device *dev, struct sk_buff *skb,
> +                          struct mfc_cache *cache, int local);

You appear to have spaces here, not tabs.

    Andrew
