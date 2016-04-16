From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: reduce usage of synchronize_net in
 ndo_stop
Date: Sat, 16 Apr 2016 18:24:03 -0400 (EDT)
Message-ID: <20160416.182403.2243744047956621042.davem@davemloft.net>
References: <1460198783-10026-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbcDPWYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:24:05 -0400
In-Reply-To: <1460198783-10026-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat,  9 Apr 2016 12:46:23 +0200

> We only need to do the synchronize_net dance once for both, ipv4 and
> ipv6 sockets, thus removing one synchronize_net in case both sockets get
> dismantled.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
