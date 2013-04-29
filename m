From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: defer net_secret[] initialization
Date: Mon, 29 Apr 2013 15:16:41 -0400 (EDT)
Message-ID: <20130429.151641.88899052800399909.davem@davemloft.net>
References: <1367251132.8964.325.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759975Ab3D2TQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:16:43 -0400
In-Reply-To: <1367251132.8964.325.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 29 Apr 2013 08:58:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Instead of feeding net_secret[] at boot time, defer the init
> at the point first socket is created.
> 
> This permits some platforms to use better entropy sources than
> the ones available at boot time.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
