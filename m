From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/13] cxgb3 - use immediate data for offload Tx
Date: Tue, 14 Aug 2007 16:25:32 -0700
Message-ID: <46C239EC.7000505@chelsio.com>
References: <20070811062949.8076.42523.stgit@speedy5> <46C14106.4080604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:8583 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761181AbXHNXZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 19:25:36 -0400
In-Reply-To: <46C14106.4080604@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
>
> Divy Le Ray wrote:
> > From: Divy Le Ray <divy@chelsio.com>
> >
> > Send small TX_DATA work requests as immediate data even when
> > there are fragments.
> >
> > Signed-off-by: Divy Le Ray <divy@chelsio.com>
> > ---
> >
> >  drivers/net/cxgb3/sge.c |   17 +++++++++++------
> >  1 files changed, 11 insertions(+), 6 deletions(-)
>
> needs additional explanation.  don't just describe the new post-change
> behavior, describe why this change is needed.
>
>
It's an optimization avoiding doing multiple DMAs for small fragmented 
packets.
The driver already implements this optimization for small contiguous 
packets.

Divy
