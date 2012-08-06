From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: Re: skb_warn_bad_offload with kernel 3.5 (maybe gso/bridge
 related ?)
Date: Mon, 6 Aug 2012 13:50:09 +0300
Message-ID: <1344250209.24187.1.camel@lb-tlvb-dmitry>
References: <501B8792.6040605@univ-nantes.fr>
 <1343983887.9299.817.camel@edumazet-glaptop>
 <1344008408.4642.160.camel@deadeye.wl.decadent.org.uk>
 <20120806091846.GA18581@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Yann Dupont" <Yann.Dupont@univ-nantes.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3515 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755801Ab2HFKuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Aug 2012 06:50:14 -0400
In-Reply-To: <20120806091846.GA18581@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 17:18 +0800, Herbert Xu wrote:
> On Fri, Aug 03, 2012 at 04:40:08PM +0100, Ben Hutchings wrote:
> >
> > I think GRO is doing the right thing, and I can't think why we should
> > see ip_summed = CHECKSUM_PARTIAL if the skb is forwarded by a bridge.  I
> 
> If it is was created by GRO then it should always be CHECKSUM_PARTIAL,
> even if it came through a bridge.
> 
> Cheers,

Is LRO on for bnx2x device? It should be off when forwarding is enabled.
