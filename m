From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: csum offload and af_packet
Date: Tue, 12 Aug 2008 18:17:19 +0200
Message-ID: <200808121817.19662.netdev@axxeo.de>
References: <E1KSU3v-00037r-00@gondolin.me.apana.org.au> <20080811.175154.168708843.davem@davemloft.net> <20080812005839.GC18547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rusty@rustcorp.com.au,
	anthony@codemonkey.ws, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:56432 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754389AbYHLQRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2008 12:17:50 -0400
In-Reply-To: <20080812005839.GC18547@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu schrieb:
> The only time you need this is when you have an old guest that
> you cannot modify.  If you could modify it you can always give it
> a patched DHCP client (I've alread patched dhcp-client for Xen
> so that should work properly for KVM/lguest if you're using the
> latest version).

Are you talking about modifying the KVM client image?
There may be reasons, why this is impossible or at least highly undesired.

Before virtualisation developers of embedded stuff need to seal away
their whole machines for their development and test environment 
together with sample hardware.

Now using virtualisation they can at least virtualize their development
and test environment, save lots of cost and not risking that their sealed 
away hardware will not start again, when they need to fix a critical bug 
10-20 years later.

Now try to have them change the KVM client image :-)

Extreme special case, not worth optimizing for, I know. But that special
case is a legal one like any other special case we care about now.


Best Regards

Ingo Oeser
