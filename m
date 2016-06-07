From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 5/6] net: dsa: Initialize CPU port ethtool
 ops per tree
Date: Tue, 7 Jun 2016 23:51:20 +0200
Message-ID: <20160607215120.GF28994@lunn.ch>
References: <1465333616-6351-1-git-send-email-f.fainelli@gmail.com>
 <1465333616-6351-6-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38305 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751475AbcFGVvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 17:51:23 -0400
Content-Disposition: inline
In-Reply-To: <1465333616-6351-6-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +int dsa_cpu_port_ethtool_setup(struct dsa_switch_tree *dst,
> +			       struct dsa_switch *ds)
> +{
> +	struct net_device *master;
> +	struct ethtool_ops *cpu_ops;
> +
> +	master = ds->dst->master_netdev;

You pass in dst as a parameter, and then don't use it!

> +void dsa_cpu_port_ethtool_restore(struct dsa_switch_tree *dst,
> +				  struct dsa_switch *ds)
> +{
> +	struct net_device *master;
> +
> +	master = ds->dst->master_netdev;

Same here.

     Andrew
