From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Thu, 05 Mar 2009 13:30:26 +0100
Message-ID: <1236256226.18385.30.camel@sakura.staff.proxad.net>
References: <49AE509B.3000305@trash.net>
	 <20090304.025914.149394356.davem@davemloft.net> <49AE69DD.80802@trash.net>
	 <20090304.195328.106253933.davem@davemloft.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, bart@jukie.net, greearb@candelatech.com,
	shemminger@vyatta.com, dada1@cosmosbay.com,
	frank.blaschka@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb2-g21.free.fr ([212.27.42.10]:43301 "EHLO
	smtpfb2-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbZCEMbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 07:31:25 -0500
In-Reply-To: <20090304.195328.106253933.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2009-03-04 at 19:53 -0800, David Miller wrote:

Hi David,

> +#ifdef CONFIG_COMPAT_NET_DEV_OPS
> +       const struct net_device_ops *ops = dev->netdev_ops;
> +
> +       dev->init = ops->ndo_init;
> +       dev->uninit = ops->ndo_uninit;
> +       dev->open = ops->ndo_open;
> +       dev->change_rx_flags = ops->ndo_change_rx_flags;
> +       dev->set_rx_mode = ops->ndo_set_rx_mode;
> +       dev->set_multicast_list = ops->ndo_set_multicast_list;
> +       dev->set_mac_address = ops->ndo_set_mac_address;
> +       dev->validate_addr = ops->ndo_validate_addr;
> +       dev->do_ioctl = ops->ndo_do_ioctl;
> +       dev->set_config = ops->ndo_set_config;
> +       dev->change_mtu = ops->ndo_change_mtu;
> +       dev->tx_timeout = ops->ndo_tx_timeout;
> +       dev->get_stats = ops->ndo_get_stats;
> +       dev->vlan_rx_register = ops->ndo_vlan_rx_register;
> +       dev->vlan_rx_add_vid = ops->ndo_vlan_rx_add_vid;
> +       dev->vlan_rx_kill_vid = ops->ndo_vlan_rx_kill_vid;
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       dev->poll_controller = ops->ndo_poll_controller;
> +#endif
> +#endif
> +}
> +EXPORT_SYMBOL(netdev_resync_ops);

Any reason dev->stop is not in this list ?

Regards,

-- 
Maxime


