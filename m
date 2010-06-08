From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: avoid two atomic ops in
 ip_rcv_options()
Date: Mon, 07 Jun 2010 21:26:35 -0700 (PDT)
Message-ID: <20100607.212635.22019579.davem@davemloft.net>
References: <1275918886.2545.87.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752352Ab0FHE0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:26:24 -0400
In-Reply-To: <1275918886.2545.87.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 07 Jun 2010 15:54:46 +0200

> in_dev_get() -> __in_dev_get_rcu() in a rcu protected function.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
