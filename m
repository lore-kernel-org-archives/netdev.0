From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Fri, 12 Apr 2013 13:15:07 -0400 (EDT)
Message-ID: <20130412.131507.1181468300165616785.davem@davemloft.net>
References: <D6EA916C7149064CB4D5C686612478A3183E2D27D1@MX34A.corp.emc.com>
	<027526AF93736D4380632CD4F3B42B80030B85@MX101CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, yinglin.sun@emc.com,
	lakshmanan.prithviraj@emc.com, netdev@vger.kernel.org,
	hannes@stressinduktion.org, eric.dumazet@gmail.com
To: Jilin.Meng@emc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab3DLRPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 13:15:09 -0400
In-Reply-To: <027526AF93736D4380632CD4F3B42B80030B85@MX101CL02.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Meng, Jilin" <Jilin.Meng@emc.com>
Date: Fri, 12 Apr 2013 07:45:54 +0000

> This version accepted David's comments of coding style, Eric's comments of ether_addr_equal_64bits(), and Hannes' comments of eth_hdr(), etc.
> 
> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address while the switch side isn't configured bonding/channel yet.

Please format your commit messages properly, specifically fix these
long lines of text that extend past 80 columns.

Just because it looks properly formatted in your email client, doesn't
mean it actually is.

Please, therefore, make sure that lines do not extend past 80 columns
without a newline.
