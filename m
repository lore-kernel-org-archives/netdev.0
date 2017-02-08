From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net-next] enic: add udp_tunnel ndo for vxlan offload
Date: Wed, 08 Feb 2017 14:56:42 -0500 (EST)
Message-ID: <20170208.145642.2110647833080965561.davem@davemloft.net>
References: <20170208072825.3144-1-gvaradar@cisco.com>
        <20170208072825.3144-3-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57764 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdBHT6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:58:19 -0500
In-Reply-To: <20170208072825.3144-3-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Tue,  7 Feb 2017 23:28:24 -0800

> +static void enic_udp_tunnel_add(struct net_device *netdev,
> +				struct udp_tunnel_info *ti)
> +{
> +	struct enic *enic = netdev_priv(netdev);
> +	int err;
> +	__be16 port = ti->port;

Again, please order local variable declarations from longest to shortest
line.
