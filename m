From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: Initialize network_header and
 transport_header in vnet_rx_one()
Date: Tue, 19 Jan 2016 14:48:36 -0500 (EST)
Message-ID: <20160119.144836.425047089281018796.davem@davemloft.net>
References: <20160118211209.GB12034@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rashmi.narasimhan@oracle.com,
	david.stevens@oracle.com
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932533AbcASTsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 14:48:38 -0500
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

Applied to 'net', thanks.
