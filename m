From: David Miller <davem@davemloft.net>
Subject: Re: more info on ipsec-related invalid trusize
Date: Tue, 25 Nov 2008 21:50:01 -0800 (PST)
Message-ID: <20081125.215001.188137211.davem@davemloft.net>
References: <20081125042752.GA4085@x200.localdomain>
	<E1L4vWi-0006zm-PX@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57066
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752008AbYKZFuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:50:02 -0500
In-Reply-To: <E1L4vWi-0006zm-PX@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 25 Nov 2008 18:52:16 +0800

> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> > http://bugzilla.kernel.org/show_bug.cgi?id=10996
> > http://marc.info/?l=linux-netdev&m=122641698504902&w=2
> > 
> > SKB BUG: Invalid truesize (344) len=134, sizeof(sk_buff)=216
> > 
> > This correlates with ping6 the box to death with the following IPsec
> > configuration and entering/leaving tcpdumping on the other end.
> 
> It's a known problem.  When we expand packet headers in IPsec
> we're not adjusting the truesize.

Care to elaborate on this a little bit more to refresh
everyone's memory and perhaps someone can work on a fix?

Thanks!
