From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH RESEND] atl1: fix 4G memory corruption bug
Date: Mon, 26 May 2008 15:02:44 -0500
Message-ID: <20080526150244.165fffdd@osprey.hogchain.net>
References: <20080522220025.GA566@martell.zuzino.mipt.ru>
	<4835E39E.90801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, csnook@redhat.com,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:64535 "EHLO
	fmailhost01.isp.att.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754783AbYEZUCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 16:02:47 -0400
In-Reply-To: <4835E39E.90801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 May 2008 17:20:30 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Alexey Dobriyan wrote:
> > From: Alexey Dobriyan <adobriyan@gmail.com>
> > 
> > When using 4+ GB RAM and SWIOTLB is active, the driver corrupts
> > memory by writing an skb after the relevant DMA page has been
> > unmapped.  Although this doesn't happen when *not* using bounce
> > buffers, clearing the pointer to the DMA page after unmapping
> > it fixes the problem.
> > 
> > http://marc.info/?t=120861317000005&r=2&w=2
> > 
> > 
> > Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> > Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> > ---
> > 
> >  drivers/net/atlx/atl1.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> applied

Hi Jeff,

Where did you apply this patch?  I don't exclude the possibility that I
goofed when I fetched them, but I can't find it in any of the following
branches of your netdev tree.

	master
	net-2.6
	net-next
	upstream
	upstream-davem
	upstream-next
	upstream-next-davem

Thanks,
Jay
