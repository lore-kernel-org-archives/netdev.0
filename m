From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Wed, 19 Mar 2014 23:40:08 -0400 (EDT)
Message-ID: <20140319.234008.1455466461924213265.davem@davemloft.net>
References: <OFEB1030F8.C147FA77-ON87257C9F.005CF370-87257C9F.005CF375@us.ibm.com>
	<CAF1J0HOTLvyaWdmYLGLPn9AJLR6rQr4fk8EVFSzv5sckLuBwvw@mail.gmail.com>
	<OFA5522ACE.EF0D1366-ON87257CA0.00707184-87257CA0.00707189@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike.rapoport@ravellosystems.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41713 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaCTDkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 23:40:12 -0400
In-Reply-To: <OFA5522ACE.EF0D1366-ON87257CA0.00707184-87257CA0.00707189@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Wed, 19 Mar 2014 14:28:11 -0600

> 
> 
> -----David Miller <davem@davemloft.net> wrote: -----
> 
>>The way I read things, we would receive packets unconditionally in
>>the
>>pre-ipv6-support code. So we have to keep doing so.
> 
> I never tried it, but as there are IP-version-specific processing (the
> whole reason we need to check to support both), I'd expect
> that before the v6 support patch, v6-encapsulated packets would have
> been dropped, or at least mishandled. We accepted all v4 packets,
> because v4 is all that was supported.

I'm not suggesting to mix protocols, I'm suggesting that the IPV4
path continues to accept all IPV4 packets.

And we know exactly what protocol it is because the vs->rcv() caller
is going to be ipv4 or ipv6 specific code.
