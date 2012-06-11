From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: keep name_hlist close to name
Date: Mon, 11 Jun 2012 13:11:38 -0700 (PDT)
Message-ID: <20120611.131138.1408293576594519909.davem@davemloft.net>
References: <1339432573.6001.2429.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126Ab2FKULm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 16:11:42 -0400
In-Reply-To: <1339432573.6001.2429.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Jun 2012 18:36:13 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> __dev_get_by_name() is slow because pm_qos_req has been inserted between
> name[] and name_hlist, adding cache misses.
> 
> pm_qos_req has nothing to do at the beginning of struct net_device
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
