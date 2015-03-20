From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] bonding: ban stacked bonding support
Date: Fri, 20 Mar 2015 20:43:09 +0300
Message-ID: <20150320174308.GA2005@p183.telecom.by>
References: <20150220222042.GA15595@p183.telecom.by>
 <22754.1424474040@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33401 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751177AbbCTRnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 13:43:10 -0400
Received: by wixw10 with SMTP id w10so165282wix.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 10:43:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <22754.1424474040@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 03:14:00PM -0800, Jay Vosburgh wrote:
> 	Instead of a separate block for IFF_MASTER, the IFF_SLAVE line
> could be replaced with something like:
> 
> 	if (netif_is_bond_slave(slave_dev) || netif_is_bond_master(slave_dev)) {
> 		netdev_dbg(bond_dev, "Error: Device is bond slave or master\n");

I think separate error messages are better (kernel can distinguish between
two anyway).
