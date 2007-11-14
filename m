From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPSEC]: Add async resume support on input
Date: Tue, 13 Nov 2007 22:38:03 -0800 (PST)
Message-ID: <20071113.223803.40309642.davem@davemloft.net>
References: <20071114062834.GB11173@gondor.apana.org.au>
	<20071113.223356.216207937.davem@davemloft.net>
	<20071114063657.GA11293@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33970
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758648AbXKNGiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 01:38:04 -0500
In-Reply-To: <20071114063657.GA11293@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 14 Nov 2007 14:36:58 +0800

> On Tue, Nov 13, 2007 at 10:33:56PM -0800, David Miller wrote:
> >
> > Also applied to net-2.6.25, thanks.
> > 
> > I'll work on integrating Patrick's NF_INET_* patch next.
> 
> Thanks! With that you would be able to remove the nf_post_routing
> field from xfrm_state_afinfo.

We need to fix something else up first :-)

net/ipv4/xfrm4_input.c: In function 'xfrm4_transport_finish':
net/ipv4/xfrm4_input.c:65: error: implicit declaration of function 'xfrm4_rcv_encap_finish'
net/ipv4/xfrm4_input.c:67: error: 'nexthdr' undeclared (first use in this function)
net/ipv4/xfrm4_input.c:67: error: (Each undeclared identifier is reported only once
net/ipv4/xfrm4_input.c:67: error: for each function it appears in.)
make[2]: *** [net/ipv4/xfrm4_input.o] Error 1
make[1]: *** [net/ipv4] Error 2
make: *** [net] Error 2
