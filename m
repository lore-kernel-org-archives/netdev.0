From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] netdev_features: Add NETIF_F_TSO_MANGLEID to
 NETIF_F_ALL_TSO
Date: Sat, 16 Apr 2016 19:15:07 -0400 (EDT)
Message-ID: <20160416.191507.383764314303192016.davem@davemloft.net>
References: <20160414210434.14117.52071.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, netdev@vger.kernel.org,
	alexander.duyck@gmail.com, tom@herbertland.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbcDPXPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 19:15:09 -0400
In-Reply-To: <20160414210434.14117.52071.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Thu, 14 Apr 2016 17:04:34 -0400

> I realized that when I added NETIF_F_TSO_MANGLEID as a TSO type I forgot to
> add it to NETIF_F_ALL_TSO.  This patch corrects that so the flag will be
> included correctly.
> 
> The result should be minor as it was only used by a few drivers and in a
> few specific cases such as when NETIF_F_SG was not supported on a device so
> the TSO flags were cleared.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Applied.
