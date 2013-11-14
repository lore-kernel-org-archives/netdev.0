From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] ipv4: fix possible seqlock deadlock
Date: Thu, 14 Nov 2013 16:44:02 -0500
Message-ID: <20131114214402.GA23872@redhat.com>
References: <20131114191621.GB9630@redhat.com>
 <1384458103.28716.33.camel@edumazet-glaptop2.roam.corp.google.com>
 <1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60576 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757150Ab3KNVoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 16:44:11 -0500
Content-Disposition: inline
In-Reply-To: <1384465074.28716.41.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 14, 2013 at 01:37:54PM -0800, Eric Dumazet wrote:
 > From: Eric Dumazet <edumazet@google.com>
 > 
 > ip4_datagram_connect() being called from process context,
 > it should use IP_INC_STATS() instead of IP_INC_STATS_BH()
 > otherwise we can deadlock on 32bit arches, or get corruptions of
 > SNMP counters.
 > 
 > Fixes: 584bdf8cbdf6 ("[IPV4]: Fix "ipOutNoRoutes" counter error for TCP and UDP")

whoa, 2007. Any idea why I only just started hitting this ?

	Dave
