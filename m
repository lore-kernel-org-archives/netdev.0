From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core functions cleanup
Date: Sun, 29 Dec 2013 16:38:37 -0500 (EST)
Message-ID: <20131229.163837.1945500773943196945.davem@davemloft.net>
References: <20131229113833.2a43b4e4@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48429 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3L2Vik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Dec 2013 16:38:40 -0500
In-Reply-To: <20131229113833.2a43b4e4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 29 Dec 2013 11:38:33 -0800

> @@ -1566,14 +1565,13 @@ EXPORT_SYMBOL(unregister_netdevice_notif
>   *	are as for raw_notifier_call_chain().
>   */
>  
> -int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
> +static int call_netdevice_notifiers_info(unsigned long val, struct net_device *dev,
>  				  struct netdev_notifier_info *info)

Please reindent.
