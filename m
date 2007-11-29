From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] [IPSEC]: Reinject v6 packet on input
	instead	of	calling netfilter
Date: Thu, 29 Nov 2007 17:05:56 -0500
Message-ID: <1196373956.5699.2.camel@localhost>
References: <1196369551.4437.24.camel@localhost>
	 <474F275D.3030401@trash.net> <1196370761.4437.28.camel@localhost>
	 <474F2D41.60707@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.182]:2202 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761284AbXK2WGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 17:06:00 -0500
Received: by py-out-1112.google.com with SMTP id u77so3897974pyb
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 14:05:59 -0800 (PST)
In-Reply-To: <474F2D41.60707@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-29-11 at 22:21 +0100, Patrick McHardy wrote:

> 
> http://lists.openwall.net/netdev/2007/10/16/88
> > I wouldnt mind just ipv4 going in - but that would be lacking
> > consistency. Is there anything that can be done to get the extension
> > headers to be processed only once?
> >   
> 
> I would prefer to keep things consistent between IPv4 and IPv6. 

Makes sense.

> Not sure if anything could be done, perhaps we could keep the necessary
> parts of the IP6CB and skip parsing up to the ESP nexthdr.

I will compute in the background and talk to Yoshfuji (hopefully will
bump into him next week;->). Herbert, if you have any clever ideas
please shoot.

cheers,
jamal

