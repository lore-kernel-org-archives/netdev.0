From: Tetja Rediske <tetja@tetja.de>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Mon, 8 Apr 2013 11:56:51 +0200
Message-ID: <20130408115651.445341f5@trediske.ws.office.manitu.net>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net>
	<1460015.zN3jPXiAbD@cpaasch-mac>
	<1365270879.3887.4.camel@edumazet-glaptop>
	<2517820.omWyusa00U@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	djduanjiong@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from 159.75.238.89.in-addr.arpa.manitu.net ([89.238.75.159]:58012
	"EHLO mail.py-ro.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S935361Ab3DHJ44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 05:56:56 -0400
In-Reply-To: <2517820.omWyusa00U@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> I made a setup to trigger the ICMPv6 Redirect.
> Yes, the bug was added by ec18d9a26 (ipv6: Add redirect support to
> all protocol icmp error handlers.), but prior to 093d04d4 (ipv6:
> Change skb->data before using icmpv6_notify() to propagate redirect)
> the stack did not enter tcp_v6_err upon a redirect message.
> 
> This, because inside icmpv6_notify, skb->data did not point to the
> inner IP header. So, when icmpv6_notify looks up the
> protocol-handler, it will not match on tcp_v6_err.

with the goto line I can't see this behaviour anymore.

Thanks!

Tetja
