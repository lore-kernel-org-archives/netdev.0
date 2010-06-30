From: Simon Horman <horms@verge.net.au>
Subject: Re: static inline int xfrm_mark_get() broken
Date: Wed, 30 Jun 2010 16:01:21 +0900
Message-ID: <20100630070121.GA26582@verge.net.au>
References: <4C28EE19.2090502@hsr.ch>
 <20100630044637.GV2138@verge.net.au>
 <4C2AD009.40306@hsr.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Steffen Andreas (asteffen@hsr.ch)" <asteffen@hsr.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jamal <hadi@cyberus.ca>
To: Andreas Steffen <andreas.steffen@hsr.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41699 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398Ab0F3HBX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jun 2010 03:01:23 -0400
Content-Disposition: inline
In-Reply-To: <4C2AD009.40306@hsr.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 30, 2010 at 07:03:05AM +0200, Andreas Steffen wrote:
> Hello Simon,
> 
> actually I don't care how this bug is going to be fixed, but with
> sizeof(struct xfrm_mark) I'm dead certain that both the mark
> value and mask are being copied. Actually in the next inline
> function right below sizeof(struct xfrm_mark) is used, too:
> 
> static inline int xfrm_mark_put(struct sk_buff *skb, struct xfrm_mark *m)
> {
>     if (m->m | m->v)
>        NLA_PUT(skb, XFRMA_MARK, sizeof(struct xfrm_mark), m);
>     return 0;

In that case I withdraw my suggestion.
