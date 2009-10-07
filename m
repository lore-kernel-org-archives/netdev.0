From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] be2net: Bug fix to properly update ethtool
 tx-checksumming after ethtool -K <ifname> tx off
Date: Tue, 06 Oct 2009 17:35:41 -0700 (PDT)
Message-ID: <20091006.173541.24302637.davem@davemloft.net>
References: <20091005122207.GA22935@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933806AbZJGAfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 20:35:45 -0400
In-Reply-To: <20091005122207.GA22935@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitk@serverengines.com>
Date: Mon, 5 Oct 2009 17:52:19 +0530

> This is a fix for a bug which was a result of wrong use of checksum offload flag.
> The status of tx-checksumming was not changed from on to off
> after a 'ethtool -K <ifname> tx off' operation.
> Use the proper checksum offload flag NETIF_F_HW_CSUM instead of 
> NETIF_F_IP_CSUM and NETIF_F_IPV6_CSUM.
> Patch is against net-2.6 tree.
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
