From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Thu, 4 Jan 2007 21:27:07 +1100
Message-ID: <20070104102707.GA7662@gondor.apana.org.au>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104080351.GA1740@ff.dom.local> <20070104082930.GB7006@gondor.apana.org.au> <20070104085014.GA2500@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>, greearb@candelatech.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2387 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932342AbXADK1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 05:27:37 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070104085014.GA2500@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 04, 2007 at 09:50:14AM +0100, Jarek Poplawski wrote:
> 
> Could you explain? I can see some inet_rtm_newaddr
> interrupted. For me it could be e.g.:
> 
> after
> vconfig add eth0 9
> 
> ip addr add dev eth0.9 ...

Whether eth0.9 is up or not does not affect this at all.  The spin
locks are initialised (and used) when the first IPv4 address is added,
not when the device comes up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
