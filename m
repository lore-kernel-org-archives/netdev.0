From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] netdev_features: Fold NETIF_F_ALL_TSO
 into NETIF_F_GSO_SOFTWARE
Date: Thu, 21 Apr 2016 14:15:09 -0400 (EDT)
Message-ID: <20160421.141509.2020522861813264622.davem@davemloft.net>
References: <20160419180219.11003.78651.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752149AbcDUSPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:15:12 -0400
In-Reply-To: <20160419180219.11003.78651.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Tue, 19 Apr 2016 14:02:19 -0400

> This patch folds NETIF_F_ALL_TSO into the bitmask for NETIF_F_GSO_SOFTWARE.
> The idea is to avoid duplication of defines since the only difference
> between the two was the GSO_UDP bit.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied.
