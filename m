From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] net-tcp: fix panic in tcp_fastopen_cache_set()
Date: Thu, 14 Nov 2013 12:55:14 -0500
Message-ID: <20131114175514.GA9630@redhat.com>
References: <20131113204543.GA26715@redhat.com>
 <1384382413.28458.132.camel@edumazet-glaptop2.roam.corp.google.com>
 <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754860Ab3KNRz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 12:55:26 -0500
Content-Disposition: inline
In-Reply-To: <1384383646.28458.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 03:00:46PM -0800, Eric Dumazet wrote:
 > From: Eric Dumazet <edumazet@google.com>
 > 
 > We had some reports of crashes using TCP fastopen, and Dave Jones
 > gave a nice stack trace pointing to the error.
 > 
 > Issue is that tcp_get_metrics() should not be called with a NULL dst
 > 
 > Fixes: 1fe4c481ba637 ("net-tcp: Fast Open client - cookie cache")
 > Signed-off-by: Eric Dumazet <edumazet@google.com>
 > Reported-by: Dave Jones <davej@redhat.com>
 > Cc: Yuchung Cheng <ycheng@google.com>

I let this run overnight, looks good.

Tested-by: Dave Jones <davej@fedoraproject.org>

thanks Eric.
 
	Dave
