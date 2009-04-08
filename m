From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 8 Apr 2009 14:51:46 +0800
Message-ID: <20090408065146.GA22852@gondor.apana.org.au>
References: <1238701718.5669.26.camel@bender> <20090407072647.GA11480@gondor.apana.org.au> <1239108520.32737.28.camel@dogo.mojatatu.com> <20090407130447.GA14329@gondor.apana.org.au> <1239112067.32737.51.camel@dogo.mojatatu.com> <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56869 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752459AbZDHGwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 02:52:02 -0400
Content-Disposition: inline
In-Reply-To: <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 07, 2009 at 04:38:01PM +0200, Johann Baudy wrote:
>
> Do you think this solution is not acceptable?

Not unless you can figure out a way to prevent netfilter from
being run on your packet.  The two hurdles you have to overcome
are act_ipt and bridge netfilter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
