From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] l2tp_eth: fix memory allocation
Date: Fri, 23 Apr 2010 16:37:54 -0700 (PDT)
Message-ID: <20100423.163754.252827908.davem@davemloft.net>
References: <20100423110151.GB2853@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55534
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755062Ab0DWXht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:37:49 -0400
In-Reply-To: <20100423110151.GB2853@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Fri, 23 Apr 2010 13:01:52 +0200

> Since .size is set properly in "struct pernet_operations l2tp_eth_net_ops",
> allocating space for "struct l2tp_eth_net" by hand is not correct, even causes
> memory leakage.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Also applied, thanks Jiri.
