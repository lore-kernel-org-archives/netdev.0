From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: Initialize network_header and
 transport_header in vnet_rx_one()
Date: Mon, 18 Jan 2016 17:20:22 -0500 (EST)
Message-ID: <20160118.172022.2052673337766512747.davem@davemloft.net>
References: <20160118211209.GB12034@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rashmi.narasimhan@oracle.com,
	david.stevens@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932372AbcARWU2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 17:20:28 -0500
In-Reply-To: <20160118211209.GB12034@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 18 Jan 2016 16:12:09 -0500

> vnet_fullcsum() accesses ip_hdr() and transport header to compute
> the checksum for IPv4 packets, so these need to be initialized in
> skb created in vnet_rx_one().
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

If this is a bug fix, why are you targetting net-next?
