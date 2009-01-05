From: David Miller <davem@davemloft.net>
Subject: Re: [UNTESTED] Add hardware-assisted VLAN support for GRO
Date: Sun, 04 Jan 2009 22:57:27 -0800 (PST)
Message-ID: <20090104.225727.236263263.davem@davemloft.net>
References: <20090102054714.GA23106@gondor.apana.org.au>
	<20090102054921.GA23174@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46912
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751301AbZAEG51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 01:57:27 -0500
In-Reply-To: <20090102054921.GA23174@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 2 Jan 2009 16:49:21 +1100

> On Fri, Jan 02, 2009 at 04:47:14PM +1100, Herbert Xu wrote:
> >
> > vlan: Add GRO interfaces
> > 
> > This patch adds GRO interfaces for hardware-assisted VLAN reception.
> > With this in place we're now at parity with LRO as far as the
> > interface is concerned.  That is, you can now take any LRO driver
> > and convert it over to GRO.
> 
> Here's an updated description for the 2nd patch:

These changes look fine to me, although the skb->dev trick
is... exciting :-)

Please resubmit these changes individually when you've tested
them, thanks!
