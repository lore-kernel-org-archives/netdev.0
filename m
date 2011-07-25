From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Mon, 25 Jul 2011 11:46:05 +0800
Message-ID: <20110725034605.GA28059@gondor.apana.org.au>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net> <20110722092159.GA20722@gondor.apana.org.au> <4E2ADB39.9070409@gmail.com> <20110723152724.GA11028@gondor.apana.org.au> <20110723093743.7c90b78f@nehalam.ftrdhcpuser.net> <20110724001816.GA14051@gondor.apana.org.au> <4E2BD96E.4090101@gmail.com> <20110724202620.1456e742@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, David Miller <davem@davemloft.net>,
	jbohac@suse.cz, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54822 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497Ab1GYDqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 23:46:19 -0400
Content-Disposition: inline
In-Reply-To: <20110724202620.1456e742@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 24, 2011 at 08:26:20PM -0700, Stephen Hemminger wrote:
>
> Since virtual machines should be using virtio network devices, shouldn't
> the suspend/resume in that device just work. It doesn't need to drop the link.

The VM may also be using SRIOV.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
