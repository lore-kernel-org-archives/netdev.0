From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: lock socket in ip6_datagram_connect()
Date: Wed, 15 Jul 2015 17:26:12 -0700 (PDT)
Message-ID: <20150715.172612.2146759620527413231.davem@davemloft.net>
References: <1436854222.1374.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbGPA0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 20:26:13 -0400
In-Reply-To: <1436854222.1374.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 14 Jul 2015 08:10:22 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ip6_datagram_connect() is doing a lot of socket changes without
> socket being locked.
> 
> This looks wrong, at least for udp_lib_rehash() which could corrupt
> lists because of concurrent udp_sk(sk)->udp_portaddr_hash accesses.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
