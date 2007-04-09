From: David Miller <davem@davemloft.net>
Subject: Re: [SC92031]: Fix priv->lock context
Date: Mon, 09 Apr 2007 12:07:08 -0700 (PDT)
Message-ID: <20070409.120708.35442163.davem@davemloft.net>
References: <20070405215703.GA21219@gondor.apana.org.au>
	<20070409.115625.08346514.davem@davemloft.net>
	<461A8D9D.6070604@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, adaplas@pol.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S964960AbXDITHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2007 15:07:09 -0400
In-Reply-To: <461A8D9D.6070604@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Mon, 09 Apr 2007 15:01:49 -0400

> David Miller wrote:
> > From: Herbert Xu <herbert@gondor.apana.org.au>
> > Date: Fri, 6 Apr 2007 07:57:03 +1000
> > 
> >> On Thu, Apr 05, 2007 at 09:59:29AM -0700, David Miller wrote:
> >>> Where is the patch? :-)
> >>>
> >>> Second time you've done this in two days Herbert, tsk tsk :)))
> >> The patch was so easy that it was left as an exercise to the reader :)
> >>
> >> [SC92031]: Fix priv->lock context
> >>
> >> The spin_lock calls made in dev->open and dev->close must disable
> >> BH since open/close are made in process context.  Conversely, the
> >> call in dev->hard_start_xmit does not need to disable BH since it
> >> is already executing with BH disabled.
> >>
> >> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Applied, either Jeff or myself will make sure this gets into
> > Linus's tree.
> 
> Sounds like you got this one?

Yep.
