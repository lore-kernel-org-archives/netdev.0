From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix returned tc and hoplimit values for route with
 IPv6 encapsulation
Date: Sun, 27 Mar 2016 22:35:16 -0400 (EDT)
Message-ID: <20160327.223516.747400717075178298.davem@davemloft.net>
References: <1459094771-24749-1-git-send-email-quentin@armitage.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: quentin@armitage.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58797 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365AbcC1CfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 22:35:19 -0400
In-Reply-To: <1459094771-24749-1-git-send-email-quentin@armitage.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Armitage <quentin@armitage.org.uk>
Date: Sun, 27 Mar 2016 17:06:11 +0100

> For a route with IPv6 encapsulation, the traffic class and hop limit
> values are interchanged when returned to userspace by the kernel.
> For example, see below.
> 
>># ip route add 192.168.0.1 dev eth0.2 encap ip6 dst 0x50 tc 0x50 hoplimit 100 table 1000
>># ip route show table 1000
> 192.168.0.1  encap ip6 id 0 src :: dst fe83::1 hoplimit 80 tc 100 dev eth0.2  scope link
> 
> Signed-off-by: Quentin Armitage <quentin@armitage.org.uk>

Applied, thank you.
