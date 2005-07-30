From: Diego Beltrami <diego.beltrami@HIIT.FI>
Subject: Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Sat, 30 Jul 2005 14:01:18 +0300
Message-ID: <1122721278.3696.28.camel__49106.3119647608$1122721625$gmane$org@odysse>
References: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au>
	 <1122651216.25842.67.camel@odysse>
	 <B9CA81E3-5A80-4629-8D32-42A8C37142E2@nomadiclab.com>
	 <20050729234859.GA27325@gondor.apana.org.au>
Reply-To: diego.beltrami@HIIT.FI
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pekka Nikander <pekka.nikander@nomadiclab.com>, netdev@oss.sgi.com,
        infrahip@HIIT.FI, hipl-users@freelists.org, hipsec@ietf.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050729234859.GA27325@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> On Fri, Jul 29, 2005 at 05:45:24PM +0200, Pekka Nikander wrote:
> > >Surely BEET will work also for AH with minor changes, even though we
> > >only tried the ESP encapsulation.
> > 
> > I wouldn't be so sure.  IIRC, tunnel mode is not specified for AH but  
> > for ESP only.  Consequently, defining BEET mode for AH might be  
> 
> Well plain tunnel mode certainly is specified for AH as well as IPComp.
> But you're right the semantics of BEET mode for AH needs to be thought
> out.
> 

The Linux patch which has been presented (see URL: 
http://infrahip.hiit.fi/beet/beet-patch-v1.0-2.6.12.2 ), has been
developed based upon the design given by the draft

http://www.ietf.org/internet-drafts/draft-nikander-esp-beet-mode-03.txt

As a result BEET patch considers the ESP encapsulation as it has been
designed.

OTOH we believe the implementation is usable more or less as it is now
for AH and perhaps IPComp in the future. But, as already mentioned both
by Pekka and Herbert, this would need more thinking and designing.

The implementation is flexible enough to finetune once the semantics for
similar optimizations have been considered for AH and IPComp.

--Diego
