From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet:Invoke SET_NETDEV_DEV() to set up the
 vdev in vnet_new()
Date: Mon, 21 Sep 2015 16:28:55 -0700 (PDT)
Message-ID: <20150921.162855.1364832418265155527.davem@davemloft.net>
References: <20150918214755.GI26826@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.stevens@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbIUX24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:28:56 -0400
In-Reply-To: <20150918214755.GI26826@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Fri, 18 Sep 2015 17:47:55 -0400

> `ls /sys/devices/channel-devices/vnet-port-0-0/net' is missing without
> this change, and applications like NetworkManager are looking in
> sysfs for the information.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

This is a bug, so applied to 'net', thanks!
