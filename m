From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/2] [IPSEC]: Reinject packet instead of calling
	netfilter directly on input
Date: Mon, 03 Dec 2007 07:34:15 -0500
Message-ID: <1196685255.4515.11.camel@localhost>
References: <1196369374.4437.18.camel@localhost>
	 <20071203092144.GB22869@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	YOSHIFUJI Hideaki /
	 =?UTF-8?Q?=E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E?=
	<yoshfuji@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.184]:65206 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752366AbXLCMeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 07:34:36 -0500
Received: by rv-out-0910.google.com with SMTP id k20so2653590rvb
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2007 04:34:34 -0800 (PST)
In-Reply-To: <20071203092144.GB22869@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-03-12 at 20:21 +1100, Herbert Xu wrote:

> Sorry for the late response Jamal.  I've been too busy to give
> this issue proper thought.  It's still in my mailbox so I will
> respond to it once things quiten down a little.

I totaly empathize - take your time.

The point brought up on v6 extensions needs to be addressed. I thought
about it a little - and it is valid as well for ipv4 options; they will
be processed twice.
To build up on what Patrick said, I noticed a bit still available in the
bag right after skb->nf_trace that i could use to signal
"options/extensions already processed". 
If people think think this is a sane use of that very lonely bit, I will
post patches.
CCing Yoshfuji.

cheers,
jamal

