From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Documentation: document the gianfar tx vlan offload
 issue
Date: Fri, 04 Apr 2014 09:56:33 -0400 (EDT)
Message-ID: <20140404.095633.1081341257454844906.davem@davemloft.net>
References: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com,
	Yanjun.Zhu@windriver.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752384AbaDDNy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 09:54:58 -0400
In-Reply-To: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Fri,  4 Apr 2014 11:04:45 +0800

> +But if tx vlan tag hardware insertion is enabled, and a vlan-device is
> +created, the physical device which vlan device is on will be unable to
> +work, like:
> +
> +	$ethtool -K eth0 tx-vlan-stag-hw-insert on
> +	$ifconfig eth0 192.168.1.13/24 up
> +
> +	$vconfig add eth0 4091
> +	$ifconfig eth0.4091 10.1.1.13/24 up
> +eth0.4091 can work, but eth0 can not work, since eth0 sends the insane
> +packets out.

This is a bit of a joke.

If a configuration doesn't work properly, it should be disallowed
by the driver, rather than "documented".
