From: David Miller <davem@davemloft.net>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Sun, 25 Jun 2006 23:55:56 -0700 (PDT)
Message-ID: <20060625.235556.108743146.davem@davemloft.net>
References: <20060623233840.GA6258@gondor.apana.org.au>
	<20060623235341.GA6593@gondor.apana.org.au>
	<1151118521.7719.0.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:6303
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751188AbWFZGz5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 02:55:57 -0400
To: mchan@broadcom.com
In-Reply-To: <1151118521.7719.0.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 23 Jun 2006 20:08:41 -0700

> On Sat, 2006-06-24 at 09:53 +1000, Herbert Xu wrote:
> 
> > Nevermind, I obviously complete ignored your other fix to the length of
> > the last segment :) Here is a fixed version.
> > 
> > [NET]: Fix CHECKSUM_HW GSO problems.
> > 
> > Fix checksum problems in the GSO code path for CHECKSUM_HW packets.
> > 
> > The ipv4 TCP pseudo header checksum has to be adjusted for GSO
> > segmented packets.
> > 
> > The adjustment is needed because the length field in the pseudo-header
> > changes.  However, because we have the inequality oldlen > newlen, we
> > know that delta = (u16)~oldlen + newlen is still a 16-bit quantity.
> > This also means that htonl(delta) + th->check still fits in 32 bits.
> > Therefore we don't have to use csum_add on this operations.
> > 
> > This is based on a patch by Michael Chan <mchan@broadcom.com>.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> Yes, this should work. ACK.

Applied, thanks a lot guys.
