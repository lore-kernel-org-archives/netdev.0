From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: netlink NETLINK_ROUTE  failure & Can the kernel really handle
 IPv6 properly
Date: Mon, 6 Oct 2014 11:35:46 +0800
Message-ID: <54320E12.9080002@cn.fujitsu.com>
References: <542C63FE.9080807@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Ulf Samuelsson <netdev@emagii.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:10940 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752123AbaJFDf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 23:35:56 -0400
In-Reply-To: <542C63FE.9080807@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/02/2014 04:28 AM, Ulf Samuelsson wrote:
> 
>     nls = netlink_kernel_create( &init_net, NETLINK_ROUTE, 0, my_rcv, NULL, THIS_MODULE);

Kernel already creates NETLINK_ROUTE type netlink,
you can not create another kernel side NETLINK_ROUTE netlink socket.
