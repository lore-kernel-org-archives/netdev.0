From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH ipsec-next v3] xfrm: avoid creating temporary SA when
 there are no listeners
Date: Thu, 13 Feb 2014 13:08:26 +0100
Message-ID: <20140213120826.GC3438@secunet.com>
References: <1392213609-20098-1-git-send-email-horia.geanta@freescale.com>
 <1392214806-21966-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Horia Geanta <horia.geanta@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56178 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753199AbaBMMIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 07:08:31 -0500
Content-Disposition: inline
In-Reply-To: <1392214806-21966-1-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 04:20:06PM +0200, Horia Geanta wrote:
> In the case when KMs have no listeners, km_query() will fail and
> temporary SAs are garbage collected immediately after their allocation.
> This causes strain on memory allocation, leading even to OOM since
> temporary SA alloc/free cycle is performed for every packet
> and garbage collection does not keep up the pace.
> 
> The sane thing to do is to make sure we have audience before
> temporary SA allocation.
> 
> Signed-off-by: Horia Geanta <horia.geanta@freescale.com>

Applied to ipsec-next, thanks!
