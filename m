From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPv6: autoconfiguration and suspend/resume or link down/up
Date: Sat, 23 Jul 2011 23:27:24 +0800
Message-ID: <20110723152724.GA11028@gondor.apana.org.au>
References: <20110719180222.GA7509@midget.suse.cz> <20110722.010628.1678943945721626312.davem@davemloft.net> <20110722092159.GA20722@gondor.apana.org.au> <4E2ADB39.9070409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jbohac@suse.cz,
	netdev@vger.kernel.org, shemminger@vyatta.com
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39158 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab1GWP1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jul 2011 11:27:38 -0400
Content-Disposition: inline
In-Reply-To: <4E2ADB39.9070409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 23, 2011 at 04:31:21PM +0200, Nicolas de Peslo=FCan wrote:
>
> That being said, the time to renegotiate a network setup sounds very=20
> short, compared to the time for a full suspend-migrate-resume cycle. =
I'm=20
> not sure VM migration would really suffer from such renegotiation.

Live migration certainly would suffer from multiple RTTs that
result from renegotiation.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
