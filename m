From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: Re: [PATCH 3/3] netxen: ethtool fixes
Date: Fri, 31 Aug 2007 17:42:38 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0708311742100.19008@stellar.unminc.com>
References: <20070828115324.839681763@netxen.com> <20070828115603.981381010@netxen.com>
 <46D7F29F.4030408@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, rob@netxen.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:54960 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964928AbXHaMMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 08:12:43 -0400
In-Reply-To: <46D7F29F.4030408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

oops, ok regenerating patch 3 only.

On Fri, 31 Aug 2007, Jeff Garzik wrote:

> dhananjay@netxen.com wrote:
> > +static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
> > +{
> > +	struct netxen_adapter *adapter = netdev_priv(dev);
> > +	adapter->rx_csum = 0;
> > +	return 0;
> > +}
> 
> Bug:  'data' ignored
> 
> 
> 
