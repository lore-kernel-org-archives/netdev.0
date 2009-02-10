From: David Miller <davem@davemloft.net>
Subject: Re: TX pre-headers...
Date: Tue, 10 Feb 2009 00:15:33 -0800 (PST)
Message-ID: <20090210.001533.255492103.davem@davemloft.net>
References: <20090209.021403.56830306.davem@davemloft.net>
	<20090209101912.GA8338@gondor.apana.org.au>
	<m3zlgvaabf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbZBJIPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:15:39 -0500
In-Reply-To: <m3zlgvaabf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Mon, 09 Feb 2009 16:39:48 +0100

> OTOH I wonder if these changes make the dev->hard_header_len no longer
> needed.

Not really, this value tells the kernel how large the cached
link-level headers are that get copied directly under the
network header.

