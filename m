From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] benet: interrupt/i/o handling, network layer i/f
 and ethtool functions
Date: Tue, 09 Dec 2008 22:45:51 -0800 (PST)
Message-ID: <20081209.224551.111207580.davem@davemloft.net>
References: <1228832399.6435.95.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, jeff@garzik.org,
	subbus@serverengines.com
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36520
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753884AbYLJGpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 01:45:51 -0500
In-Reply-To: <1228832399.6435.95.camel@sperla-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 09 Dec 2008 19:49:59 +0530

> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = (struct be_net_object *)(netdev->priv);
> +	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
> +	struct be_net_object *pnob = (struct be_net_object *)netdev->priv;
> +	pnob = (struct be_net_object *)netdev->priv;
> +	struct be_net_object *pnob = dev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;
> +	struct be_net_object *pnob = netdev->priv;

Use netdev_priv() and kill casts.
