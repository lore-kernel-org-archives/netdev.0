From: David Miller <davem@davemloft.net>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 01:26:09 -0700 (PDT)
Message-ID: <20060622.012609.25474139.davem@davemloft.net>
References: <1150909982.15275.100.camel@localhost.localdomain>
	<E1FtDU0-0005nd-00@gondolin.me.apana.org.au>
	<20060622023029.GA6156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60055
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964884AbWFVI0K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:26:10 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622023029.GA6156@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 22 Jun 2006 12:30:29 +1000

> On Thu, Jun 22, 2006 at 10:55:44AM +1000, Herbert Xu wrote:
> > 
> > I think skb_padto simply shouldn't allocate a new skb.  It only needs
> > to extend the data area.
> 
> OK, here is a patch to make it do that.
> 
> [NET]: Avoid allocating skb in skb_pad

Want me to let this cook in 2.6.18 for a while before sending
it off to -stable?
