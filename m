From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 22:00:23 -0400 (EDT)
Message-ID: <20140919.220023.1543102754842079813.davem@davemloft.net>
References: <1411166670.26859.48.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7MxiP9gZe2daJunXOKNa6sQd9JZ_4_ko6ipYGtshVP0bg@mail.gmail.com>
	<1411168172.26859.61.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32878 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbaITCA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 22:00:28 -0400
In-Reply-To: <1411168172.26859.61.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Guys just change the check in macvlan to >= tx_queue_len or similar
and let's end this silly discussion.
