From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Fri, 27 Apr 2007 17:25:00 -0700
Message-ID: <20070427172500.350b7309.akpm@linux-foundation.org>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
	<4632910E.6030408@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, aabdulla@nvidia.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:49130 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757960AbXD1AZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 20:25:42 -0400
In-Reply-To: <4632910E.6030408@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Apr 2007 20:10:54 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> akpm@linux-foundation.org wrote:
> > From: Ingo Molnar <mingo@elte.hu>
> > 
> > Another forcedeth.c thing: i noticed that its NAPI handler does not do
> > tx-ring processing.  The patch below implements this - tested on DESC_VER_2
> > hardware, with CONFIG_FORCEDETH_NAPI=y.
> > 
> > Signed-off-by: Ingo Molnar <mingo@elte.hu>
> > Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  drivers/net/forcedeth.c |    8 ++++++++
> >  1 file changed, 8 insertions(+)
> 
> See thread comments -- this patch should be expanded.
> 

yeah, I added the comments to the changelog for you all to read next
time I send it ;)
