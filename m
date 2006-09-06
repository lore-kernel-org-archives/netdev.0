From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Wed, 06 Sep 2006 07:20:39 -0400
Message-ID: <1157541639.5039.28.camel@jzny2>
References: <1157204582.5197.4.camel@jzny2>
	 <20060905233823.GA9217@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:24224 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750791AbWIFLUn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 07:20:43 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GKvSW-000665-VO
	for netdev@vger.kernel.org; Wed, 06 Sep 2006 07:20:44 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060905233823.GA9217@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-09 at 09:38 +1000, Herbert Xu wrote:
> On Sat, Sep 02, 2006 at 09:43:02AM -0400, jamal wrote:
> >
> > Allow for searching the SAD from external data path points without
> > assumming L3 details. The only customer of this exposure currently
> > is pktgen.
> 
> Any reason why xfrm_state_find can't be used? 

xfrm_state_find is overkill (if you compare the two functionalities). 

> It doesn't look right
> to add generic code that's only used by pktgen.

The alternative would require heavy mods to xfrm_state_find to do the
minimal needed (a lot more than what i was asking for in mode output). I
could move the function to outside of xfrm_state.c but that would
require a few exports for it to use which looks less fair to me ;-> 

cheers,
jamal

