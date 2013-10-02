From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netfront: convert to GRO API
Date: Wed, 02 Oct 2013 15:54:45 -0400 (EDT)
Message-ID: <20131002.155445.803395191856028160.davem@davemloft.net>
References: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	konrad.wilk@oracle.com, abchak@juniper.net, ian.campbell@citrix.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3JBTyr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 15:54:47 -0400
In-Reply-To: <1380545194-13419-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Mon, 30 Sep 2013 13:46:34 +0100

> Anirban was seeing netfront received MTU size packets, which downgraded
> throughput. The following patch makes netfront use GRO API which
> improves throughput for that case.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Anirban Chakraborty <abchak@juniper.net>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Acked-by: Konrad Wilk <konrad.wilk@oracle.com>

Applied, to net-next.

Anirban suggested to queue this to -stable but that is absolutely
not appropriate so I'm not doing that.
