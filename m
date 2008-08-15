From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for
 iptables nat routing
Date: Fri, 15 Aug 2008 14:56:55 -0700 (PDT)
Message-ID: <20080815.145655.154408190.davem@davemloft.net>
References: <1218726484.23510.20.camel@2710p.home>
	<E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
	<20080815053548.GA6366@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.williamson@hp.com, kaber@trash.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54117
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755423AbYHOV44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 17:56:56 -0400
In-Reply-To: <20080815053548.GA6366@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 15 Aug 2008 15:35:48 +1000

> loopback: Drop obsolete ip_summed setting
> 
> Now that the network stack can handle inbound packets with partial
> checksums, we should no longer clobber the ip_summed field in the
> loopback driver.  This is because CHECKSUM_UNNECESSARY implies that
> the checksum field is actually valid which is not true for loopback
> packets since it's only partial (and thus complemented).
> 
> This allows packets from lo to then be SNATed to an external source
> while still preserving the checksum's validity.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I've applied this one too, let me know if I should not have :)
