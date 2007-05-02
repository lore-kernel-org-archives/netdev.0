From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Virtual ethernet device (tunnel)
Date: Wed, 02 May 2007 14:34:42 +0200
Message-ID: <46388562.9050305@trash.net>
References: <46386DFB.7090109@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>,
	Kirill Korotaev <dev@sw.ru>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Pavel Emelianov <xemul@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34297 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754191AbXEBMfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 08:35:51 -0400
In-Reply-To: <46386DFB.7090109@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Veth stands for Virtual ETHernet. It is a simple tunnel driver
> that works at the link layer and looks like a pair of ethernet
> devices interconnected with each other.
> 
> Mainly it allows to communicate between network namespaces but
> it can be used as is as well.
> 
> Eric recently sent a similar driver called etun. This
> implementation is closer to the OpenVZ one and it lacks
> some unimportant features of etun driver (like ethtool_ops)
> for simplicity.
> 
> The general difference from etun is that a netlink interface
> is used to create and destroy the pairs. The patch for an
> ip utility is also provided.


Thats a lot better than using sysfs, but I think it would be
preferrable to use rtnetlink instead of genetlink for network
configuration.
