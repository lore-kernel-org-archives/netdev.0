From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Mon, 22 Dec 2008 20:43:52 -0800 (PST)
Message-ID: <20081222.204352.26657089.davem@davemloft.net>
References: <20081219012527.GA2669@localhost.localdomain>
	<20081218.224224.227412554.davem@davemloft.net>
	<20081219134237.GA8802@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, shemminger@vyatta.com,
	jarkao2@gmail.com, netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60698
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754483AbYLWEnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 23:43:50 -0500
In-Reply-To: <20081219134237.GA8802@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 19 Dec 2008 08:42:37 -0500

> When the napi api was changed to separate its 1:1 binding to the net_device
> struct, the netif_rx_[prep|schedule|complete] api failed to remove the now
> vestigual net_device structure parameter.  This patch cleans up that api by
> properly removing it..
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
