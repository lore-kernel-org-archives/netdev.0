From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Subject: Re: ProxyARP and IPSec
Date: Fri, 22 Sep 2006 21:22:55 -0700
Message-ID: <17684.46751.466893.446331@localhost.localdomain>
References: <20060904222722.GA24078@ms2.inr.ac.ru>
	<44FD0759.8070307@zytor.com>
	<20060905090530.GA17104@ms2.inr.ac.ru>
	<20060922.133646.68153303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, hpa@zytor.com, stephen@dino.dnsalias.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from S010600014e000000.vc.shawcable.net ([70.79.40.36]:64940 "EHLO
	dino.dnsalias.com") by vger.kernel.org with ESMTP id S1750803AbWIWEXo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 00:23:44 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060922.133646.68153303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller writes:
 > Essentially, if you use ports as part of your selector,
 > then it is impossible to handle anything other than the
 > first fragment of a fragmented frame because the subsequent
 > fragments will not have the ports which you need in order
 > to match.

If you have port/protocol based selectors and you are firewalling then
re-assembly is already being done so IPsec will see the re-assembled
packet at little cost.  Alternately in a pure IPsec configuration it
possible to arrange things so that re-assembly is only done if
port/protocol based selectors are used.
