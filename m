From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: avoid creating temporary SA when there are no
 listeners
Date: Wed, 12 Feb 2014 13:09:14 +0100
Message-ID: <20140212120914.GB3438@secunet.com>
References: <1390986731-12861-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Horia Geanta <horia.geanta@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38925 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750963AbaBLMJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 07:09:21 -0500
Content-Disposition: inline
In-Reply-To: <1390986731-12861-1-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 29, 2014 at 11:12:11AM +0200, Horia Geanta wrote:
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

After merging net-next into ipsec-next, I get a build failure
when I apply your patch. Please rebase onto ipsec-next current.

Thanks!
