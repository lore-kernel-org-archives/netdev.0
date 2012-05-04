From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN
 negociation
Date: Fri, 04 May 2012 12:06:50 -0400 (EDT)
Message-ID: <20120504.120650.1991523144126931829.davem@davemloft.net>
References: <1336144442.3752.348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, perryl@google.com, mattmathis@google.com,
	ycheng@google.com, ncardwell@google.com, therbert@google.com,
	wilmer@google.com, dave.taht@bufferbloat.net, jankur@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54803 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab2EDQIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 12:08:00 -0400
In-Reply-To: <1336144442.3752.348.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 04 May 2012 17:14:02 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> It appears some networks play bad games with the two bits reserved for
> ECN. This can trigger false congestion notifications and very slow
> transferts.
> 
> Since RFC 3168 (6.1.1) forbids SYN packets to carry CT bits, we can
> disable TCP ECN negociation if it happens we receive mangled CT bits in
> the SYN packet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
