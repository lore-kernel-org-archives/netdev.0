From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 12:34:23 +0100
Message-ID: <1150976063.15275.146.camel@localhost.localdomain>
References: <20060622023029.GA6156@gondor.apana.org.au>
	 <20060622.012609.25474139.davem@davemloft.net>
	 <20060622083037.GB26083@gondor.apana.org.au>
	 <20060622.013440.97293561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:16822 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP
	id S1161067AbWFVLT7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 07:19:59 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060622.013440.97293561.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Iau, 2006-06-22 am 01:34 -0700, ysgrifennodd David Miller:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 22 Jun 2006 18:30:37 +1000
> 
> > On Thu, Jun 22, 2006 at 01:26:09AM -0700, David Miller wrote:
> > >
> > > Want me to let this cook in 2.6.18 for a while before sending
> > > it off to -stable?
> > 
> > You know I'm never one to push anything quickly so absolutely yes :)
> 
> Ok, applied to net-2.6.18 for now :)

The 8390 change (corrected version) also makes 8390.c faster so should
be applied anyway, and the orinoco one fixes some code that isn't even
needed and someone forgot to remove long ago. Otherwise the skb_padto
behaviour change with the newer skb style makes a lot more sense I
agree.

