From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: md5: fix a typo in tcp_v4_md5_lookup()
Date: Thu, 09 Apr 2015 18:13:05 -0400 (EDT)
Message-ID: <20150409.181305.1110188009467012327.davem@davemloft.net>
References: <1428615402.25985.280.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbbDIWNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 18:13:08 -0400
In-Reply-To: <1428615402.25985.280.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Apr 2015 14:36:42 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Lookup key for tcp_md5_do_lookup() has to be taken
> from addr_sk, not sk (which can be the listener)
> 
> Fixes: fd3a154a00fb ("tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good catch, applied, thanks.
