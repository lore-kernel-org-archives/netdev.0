From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 3/6] ehea: queue management
Date: Sat, 12 Aug 2006 07:52:25 +1000
Message-ID: <20060811215225.GH479@krispykreme>
References: <44D99F38.8010306@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.tip.net.au ([203.10.76.45]:22914 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932425AbWHKVzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 17:55:10 -0400
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <44D99F38.8010306@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

> --- linux-2.6.18-rc4-orig/drivers/net/ehea/ehea_ethtool.c	1969-12-31 

> +static void netdev_get_pauseparam(struct net_device *dev,
> +				  struct ethtool_pauseparam *pauseparam)
> +{
> +	printk("get pauseparam\n");
> +}

There are a number of stubbed out ethtool functions like this. Best not
to implement them and allow the upper layers to return a correct error.

Anton
