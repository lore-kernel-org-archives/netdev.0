From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH 0/3][XFRM]: Support packet processing error
	statistics.
Date: Wed, 24 Oct 2007 08:18:46 -0400
Message-ID: <1193228326.4442.12.camel@localhost>
References: <20071017.213523.58458049.davem@davemloft.net>
	 <200710231608.34661.nakam@linux-ipv6.org>
	 <1193168853.4415.56.camel@localhost>
	 <200710241230.57571.nakam@linux-ipv6.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:65072 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbXJXMSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 08:18:52 -0400
Received: by wx-out-0506.google.com with SMTP id h31so185235wxd
        for <netdev@vger.kernel.org>; Wed, 24 Oct 2007 05:18:51 -0700 (PDT)
In-Reply-To: <200710241230.57571.nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-24-10 at 12:30 +0900, Masahide NAKAMURA wrote:

> At IPsec point of view, actually "SPI mismatch" caused by user configuration
> cannot be identified easily since identify of SAD is consist of SPI, address and
> protocol(ESP/AH...) and linux SAD uses hash database. It is database identify
> mismatch. Then, SPI mismatch goes "NoStates" at my patch.
> OTOH Key mismatch goes "ProtoError" since esp[46]_input returns error.

Would be useful to just document what you said above so that user doesnt
have to intepret it.

> Thanks for pointing the RFC. I've read it, however, I cannot find them at the RFC.

My bad. 

> > In any case, it seems to me to be more accurate to not call them MIB
> > stats if they are not. This doesnt qualify using the macros, utilities
> > etc used for MIBs.
> 

BTW, I meant "doesnt disqualify them" above;-> 

> How about assuming it as "private MIB" of linux?

Ok, makes sense to me now - that would be a good choice (i dont see any
confusion with enteprise mib). 

> Shouldn't we have something after XFRM_  to distinguish from other XFRM
> macros?
> 

It is not needed - I am sorry that i missed the "Linux MIB" part in your
emails so far. That would be good enough.

> > > > 2) Why /proc? Are you going to make these available also via netlink? 
> > > 
> > > Because /proc is easy to see it without any modified application.
> > > If you want the netlink interface, I can do it as the next step. Do you want it?
> > 
> > Absolutely - it would be much appreciated. And if you dont have time, I
> > will write and test the user space part extension.
> 
> Thanks. After my first step is completed, could you write the netlink part?

Thanks.

cheers,
jamal

