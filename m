From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] devinet: inetdev_init out label moved after RCU assignment
Date: Fri, 5 Jan 2007 22:23:53 +1100
Message-ID: <20070105112353.GA21638@gondor.apana.org.au>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <20070105063844.GA1675@ff.dom.local> <20070105093846.GA21000@gondor.apana.org.au> <20070105111910.GA3650@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dlstevens@us.ibm.com,
	greearb@candelatech.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2403 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1161066AbXAELYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jan 2007 06:24:09 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070105111910.GA3650@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 12:19:10PM +0100, Jarek Poplawski wrote:
> 
> Why me? (I didn't spoil this!)

You spotted the problem, so it's only fair that you get the credit :)

> Subject: [PATCH] devinet: inetdev_init out label moved after RCU assignment
> 
> inetdev_init out label moved after RCU assignment
> (final suggestion by Herbert Xu)
> 
> Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

Thanks, looks good to me.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
