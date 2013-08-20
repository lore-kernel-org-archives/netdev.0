From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: raise IP_MAX_MTU to theoretical limit
Date: Tue, 20 Aug 2013 15:08:23 -0700 (PDT)
Message-ID: <20130820.150823.291614792734267659.davem@davemloft.net>
References: <1376878087.4226.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, kuznet@ms2.inr.ac.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47977 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441Ab3HTWIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 18:08:23 -0400
In-Reply-To: <1376878087.4226.41.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 18 Aug 2013 19:08:07 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> As discussed last year [1], there is no compelling reason
> to limit IPv4 MTU to 0xFFF0, while real limit is 0xFFFF
> 
> [1] : http://marc.info/?l=linux-netdev&m=135607247609434&w=2
> 
> Willem raised this issue again because some of our internal
> regression tests broke after lo mtu being set to 65536.
> 
> IP_MTU reports 0xFFF0, and the test attempts to send a RAW datagram of
> mtu + 1 bytes, expecting the send() to fail, but it does not.
> 
> Alexey raised interesting points about TCP MSS, that should be addressed
> in follow-up patches in TCP stack if needed, as someone could also set
> an odd mtu anyway.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks for following through on this Eric.
