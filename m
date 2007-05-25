From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] [XFRM]: Add module alias for transformation type.
Date: Fri, 25 May 2007 14:34:34 +0900 (JST)
Message-ID: <20070525.143434.108171372.yoshfuji@linux-ipv6.org>
References: <1180067003902-git-send-email-nakam@linux-ipv6.org>
	<20070525053220.GA24362@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@axxeo.de, davem@davemloft.net,
	netdev@vger.kernel.org, jmorris@namei.org, kazunori@miyazawa.org,
	mk@linux-ipv6.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33610 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbXEYFeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 01:34:37 -0400
In-Reply-To: <20070525053220.GA24362@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070525053220.GA24362@gondor.apana.org.au> (at Fri, 25 May 2007 15:32:20 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Fri, May 25, 2007 at 01:23:23PM +0900, nakam@linux-ipv6.org wrote:
> > 
> > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
> > index 1e53520..c9f895f 100644
> > --- a/include/net/xfrm.h
> > +++ b/include/net/xfrm.h
> > @@ -19,9 +19,19 @@
> >  #include <net/ipv6.h>
> >  #include <net/ip6_fib.h>
> >  
> > +#define XFRM_PROTO_ESP		50
> > +#define XFRM_PROTO_AH		51
> > +#define XFRM_PROTO_COMP		108
> > +#define XFRM_PROTO_IPIP		4
> > +#define XFRM_PROTO_IPV6		41
> > +#define XFRM_PROTO_ROUTING	IPPROTO_ROUTING
> > +#define XFRM_PROTO_DSTOPTS	IPPROTO_DSTOPTS
> 
> Could we use the existing IPPROTO_* values for all of these?

No, because they are of enums.

--yoshfuji
