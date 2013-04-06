From: Tetja Rediske <tetja@tetja.de>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Sat, 06 Apr 2013 20:27:42 +0200
Message-ID: <5160691E.2080105@tetja.de>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net>  <20130406043534.GC30194@order.stressinduktion.org>  <1460015.zN3jPXiAbD@cpaasch-mac> <1365270879.3887.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	djduanjiong@gmail.com, netdev@vger.kernel.org,
	steffen.klassert@secunet.com, Neal Cardwell <ncardwell@google.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 159.75.238.89.in-addr.arpa.manitu.net ([89.238.75.159]:56642
	"EHLO mail.py-ro.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759107Ab3DFSgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 14:36:38 -0400
In-Reply-To: <1365270879.3887.4.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> OK, it seems bug was added in commit
> ec18d9a2691d69cd14b48f9b919fddcef28b7f5c
> (ipv6: Add redirect support to all protocol icmp error handlers.)

> Not sure why Tetja Rediske  bisected t
> 093d04d42fa094f6740bb188f0ad0c215ff61e2c

there could be an simple explenation, because i couldn't realy provoke 
it with direct connected machines I did it on one of our least important 
DNS-Server, I did a "bad" everytime the connection fault and did a 
"good" after a some succesful connects (with waiting Time in between). 
If the Bug is based on an ICMPv6 redirect in the meantime a redirect 
could be sent out without me noticing. I did not keep the tcpdump 
running while bisect(?ing?).

I will happily try the patch, when I get to work Monday, weekend is 
mostly for family. ;)

Tetja
