From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp v6: fix softnet build breakage
Date: Fri, 26 Oct 2007 22:53:23 -0700 (PDT)
Message-ID: <20071026.225323.63281567.davem@davemloft.net>
References: <20071027034240.GA13016@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46805
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750894AbXJ0FxV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2007 01:53:21 -0400
In-Reply-To: <20071027034240.GA13016@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 26 Oct 2007 23:42:40 -0400

> 
> net/ipv6/tcp_ipv6.c: In function 'tcp_v6_rcv':
> net/ipv6/tcp_ipv6.c:1736: error: implicit declaration of function
> 'get_softnet_dma'
> net/ipv6/tcp_ipv6.c:1736: warning: assignment makes pointer from integer
> without a cast
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Applied, thanks Jeff.
