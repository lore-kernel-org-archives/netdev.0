From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/4] ipv4: Fix pmtu propagating
Date: Mon, 17 Oct 2011 14:18:05 +0200
Message-ID: <20111017121805.GR1830@secunet.com>
References: <20111011110922.GD1830@secunet.com>
 <20111012.170218.279202034199478303.davem@davemloft.net>
 <20111013100950.GO1830@secunet.com>
 <20111013.135808.636341622629050648.davem@davemloft.net>
 <20111014055406.GP1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50631 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303Ab1JQMSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 08:18:09 -0400
Content-Disposition: inline
In-Reply-To: <20111014055406.GP1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2011 at 07:54:06AM +0200, Steffen Klassert wrote:
> On Thu, Oct 13, 2011 at 01:58:08PM -0400, David Miller wrote:
> > 
> > Please find out exactly why dst->obsolete is non-zero on a freshly
> > looked up route.  It's unexpected.
> 
> Hm, on a slow path route lookup e.g. __mkroute_output() calls
> rt_dst_alloc() which initializes dst->obsolete to -1.

Just a follow up:
git commit d11a4dc18 (ipv4: check rt_genid in dst_check)
changed the initialization value of dst->obsolete from
0 to -1.
