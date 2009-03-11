From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp: allow timestamps even if SYN packet has tsval=0
Date: Wed, 11 Mar 2009 09:24:25 -0700 (PDT)
Message-ID: <20090311.092425.203553937.davem@davemloft.net>
References: <49B7ABF2.5040803@cosmosbay.com>
	<20090311.064710.255854254.davem@davemloft.net>
	<49B7D1F2.5090504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751282AbZCKQYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 12:24:39 -0400
In-Reply-To: <49B7D1F2.5090504@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 11 Mar 2009 16:00:02 +0100

> [PATCH] tcp: allow timestamps even if SYN packet has tsval=0
> 
> Some systems send SYN packets with apparently wrong RFC1323 timestamp
> option values [timestamp tsval=0 tsecr=0].
> It might be for security reasons (http://www.secuobs.com/plugs/25220.shtml )
> 
> Linux TCP stack ignores this option and sends back a SYN+ACK packet
> without timestamp option, thus many TCP flows cannot use timestamps
> and lose some benefit of RFC1323.
> 
> Other operating systems seem to not care about initial tsval value, and let
> tcp flows to negotiate timestamp option.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

And amusingly even Linux didn't care for ipv6 TCP sockets ;-)

Applied to net-next-2.6, thanks Eric.
