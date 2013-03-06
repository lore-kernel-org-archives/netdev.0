From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: add a missing nf_reset() in tun_net_xmit()
Date: Wed, 06 Mar 2013 16:05:44 -0500 (EST)
Message-ID: <20130306.160544.2211000354186600821.davem@davemloft.net>
References: <1362588847.15793.180.camel@edumazet-glaptop>
	<20130306.154641.1893414808816499940.davem@davemloft.net>
	<1362603757.15793.186.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3CFVFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:05:46 -0500
In-Reply-To: <1362603757.15793.186.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 06 Mar 2013 13:02:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dave reported following crash :
 ...
> This is because tun_net_xmit() needs to call nf_reset()
> before queuing skb into receive_queue
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks everyone.
