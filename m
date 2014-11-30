From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipvlan: ipvlan depends on INET and IPV6
Date: Sat, 29 Nov 2014 20:53:33 -0800 (PST)
Message-ID: <20141129.205333.1953373567676167279.davem@davemloft.net>
References: <1417065225-784-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jim.epost@gmail.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54816 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaK3EtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2014 23:49:21 -0500
In-Reply-To: <1417065225-784-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed, 26 Nov 2014 21:13:45 -0800

> This driver uses ip_out_local() and ip6_route_output() which are
> defined only if CONFIG_INET and CONFIG_IPV6 are enabled respectively.
> 
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied, thanks for fixing this.
