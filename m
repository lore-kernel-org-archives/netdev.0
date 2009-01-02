From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Fri, 2 Jan 2009 19:43:35 +1100
Message-ID: <20090102084335.GA24513@gondor.apana.org.au>
References: <20081230195858.GA23530@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:36264 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750860AbZABIoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 03:44:09 -0500
Content-Disposition: inline
In-Reply-To: <20081230195858.GA23530@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2008 at 07:58:58PM +0000, Russell King wrote:
>
> 19:47:32.174701 IP dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: . 644:3196(2552) ack 1190 win 8323

You are to be using TSO/GSO, what driver are you using and what
does ethtool -k <ifname> say? You could try disabling TSO to see
if the problem goes away with ethtool -K ifname tso off.

If you could please take a dump one hop away from your host to
see the segmented packets.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
