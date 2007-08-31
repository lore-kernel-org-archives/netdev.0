From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] netxen: ethtool fixes
Date: Fri, 31 Aug 2007 06:51:11 -0400
Message-ID: <46D7F29F.4030408@garzik.org>
References: <20070828115324.839681763@netxen.com> <20070828115603.981381010@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59493 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932320AbXHaKvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 06:51:13 -0400
In-Reply-To: <20070828115603.981381010@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dhananjay@netxen.com wrote:
> +static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
> +{
> +	struct netxen_adapter *adapter = netdev_priv(dev);
> +	adapter->rx_csum = 0;
> +	return 0;
> +}

Bug:  'data' ignored

