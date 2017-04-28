From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] esp: skip GRO for fragmented packets
Date: Fri, 28 Apr 2017 11:04:20 +0200
Message-ID: <20170428090420.GA31862@bistromath.localdomain>
References: <37d07f4c9bfaf9733d3cd90653927540e2639d39.1493288951.git.sd@queasysnail.net>
 <20170427104334.GE2649@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53748 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934924AbdD1JE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 05:04:29 -0400
Content-Disposition: inline
In-Reply-To: <20170427104334.GE2649@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-27, 12:43:35 +0200, Steffen Klassert wrote:
> On Thu, Apr 27, 2017 at 12:31:14PM +0200, Sabrina Dubroca wrote:
> > Currently, ESP4 GRO doesn't work for fragmented packets, so let's send
> > these through the normal path.
> > 
> > Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
> > Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> > ---
> > Steffen, if you prefer to drop this patch and fix this properly,
> > that's okay for me. I can't look much deeper into this right now and
> > it's broken on current net/master.
> 
> I did a fix for this last week, but forgot to submit it.
> We can fix this in inet_gro_receive(), as no GRO handler
> can really handle fragmented packets.
> 
> I'll plan to fix it with this patch:

Yeah, that looks okay to me, thanks.
Let's make sure it ends up in 4.11 (or an early 4.11.x).

-- 
Sabrina
