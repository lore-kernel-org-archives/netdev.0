From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Tue, 28 Apr 2009 08:02:17 -0700 (PDT)
Message-ID: <20090428.080217.179229201.davem@davemloft.net>
References: <20090427080501.GA21433@gondor.apana.org.au>
	<20090428061225.GA1591@gondor.apana.org.au>
	<49F71A00.5090701@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, brice@myri.com, sgruszka@redhat.com,
	netdev@vger.kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56523
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754808AbZD1PCY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:02:24 -0400
In-Reply-To: <49F71A00.5090701@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Tue, 28 Apr 2009 11:00:16 -0400

> If I can't figure out why LRO is so much faster in some cases, then I
> think maybe I'll just put together a patch which keeps LRO, and does
> GRO only if LRO is disabled.  Kind of ugly, but better than loosing
> 15% performance on some machines.

I refuse to apply such a patch.

Figure out this performance problem, don't work around it.
