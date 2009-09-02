From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 02 Sep 2009 19:49:37 +0200
Message-ID: <4A9EB031.9010006@trash.net>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com> <20090902092351.11649796@nehalam> <4A9E9D8A.50406@trash.net> <4A9EA250.2010209@gmail.com> <4A9EA8C6.2000501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51520 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138AbZIBRtm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 13:49:42 -0400
In-Reply-To: <4A9EA8C6.2000501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> vlan devices are currently not multi-queue capable.
> 
> We can do that with a new rtnl_link_ops method,
> get_tx_queues(), called from rtnl_create_link()
> 
> This new method gets num_tx_queues/real_num_tx_queues
> from real device.
> 
> register_vlan_device() is also handled.

Looks great. This will also make it easier to test multiqueue
scheduling without a multiqueue-capable device :)
