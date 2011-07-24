From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sun, 24 Jul 2011 08:18:16 +0800
Message-ID: <20110724001816.GA14051@gondor.apana.org.au>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net> <20110722092159.GA20722@gondor.apana.org.au> <4E2ADB39.9070409@gmail.com> <20110723152724.GA11028@gondor.apana.org.au> <20110723093743.7c90b78f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, David Miller <davem@davemloft.net>,
	jbohac@suse.cz, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51417 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab1GXASa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 20:18:30 -0400
Content-Disposition: inline
In-Reply-To: <20110723093743.7c90b78f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 23, 2011 at 09:37:43AM -0700, Stephen Hemminger wrote:
>
> Would it be possible to do live migration without dropping carrier
> or setting interface down?

I think LM uses the same mechanism as suspend and resume so whatever
happens in one case will happen in the other case as well.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
