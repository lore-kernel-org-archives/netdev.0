From: David Miller <davem@davemloft.net>
Subject: Re: csum offload and af_packet
Date: Sun, 17 Aug 2008 19:12:24 -0700 (PDT)
Message-ID: <20080817.191224.118214583.davem@davemloft.net>
References: <48A2C4DE.20005@trash.net>
	<20080817.160825.22400712.davem@davemloft.net>
	<48A8CCBF.3020408@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@axxeo.de,
	rusty@rustcorp.com.au, anthony@codemonkey.ws,
	netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53295
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750943AbYHRCMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 22:12:24 -0400
In-Reply-To: <48A8CCBF.3020408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 18 Aug 2008 03:13:35 +0200

> the linux support looks a lot cleaner in general

I totally disagree after having looked at this thing.

The number of ifdefs has doubled in pcap-linux.c since the last
official release, it's quite a mess.  It's still handling all sorts of
obscure bugs we had back in 2.0.x as well.


