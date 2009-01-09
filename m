From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Thu, 08 Jan 2009 21:00:58 -0800 (PST)
Message-ID: <20090108.210058.68468127.davem@davemloft.net>
References: <20090109041952.GA12087@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, bhutchings@solarflare.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750727AbZAIFA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 00:00:57 -0500
In-Reply-To: <20090109041952.GA12087@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 9 Jan 2009 15:19:53 +1100

> Jeff Garzik <jgarzik@pobox.com> wrote:
> >
> > For generic net stack flags outside the driver's control, that can 
> > easily be added to ethtool_{get,set}_flags() overriding or ignoring 
> > whatever the driver may have done.
> 
> To use the flags interface as is, you'd have to go through every
> single driver to get them to call ethtool_op_set_flags.  I'm sorry
> but I'm sticking with the current interface.

Right, the flags thing is inappropriate without major reworking for
Herbert's GRO case and therefore his choice was completely
appropriate.
