From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: Fix SIOCAX25GETINFO ioctl
Date: Tue, 22 Sep 2009 14:25:04 -0700 (PDT)
Message-ID: <20090922.142504.68195584.davem@davemloft.net>
References: <alpine.LNX.2.00.0909201226001.29572@cedric.unob.cz>
	<4AB65937.8010508@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jr+netfilter-devel@cedric.unob.cz, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33913
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753332AbZIVVYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:24:45 -0400
In-Reply-To: <4AB65937.8010508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Sep 2009 18:32:55 +0200

> [PATCH] ax25: Fix SIOCAX25GETINFO ioctl
> 
> rcv_q & snd_q initializations were reversed in commit
> 31e6d363abcd0d05766c82f1a9c905a4c974a199
> (net: correct off-by-one write allocations reports)
> 
> Signed-off-by: Jan Rafaj <jr+netfilter-devel@cedric.unob.cz>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and I'll make sure to check if it needs -stable
treatment too.

Thanks.
