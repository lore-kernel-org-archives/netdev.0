From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 3/3] smc911x: Make the driver safer on SMP
Date: Wed, 22 Oct 2008 12:04:08 +0100
Message-ID: <1224673448.705.6.camel@pc1117.cambridge.arm.com>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com>
	 <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
	 <48FF0807.8060501@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([193.131.176.58]:55529 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753515AbYJVLEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 07:04:16 -0400
In-Reply-To: <48FF0807.8060501@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-10-22 at 07:01 -0400, Jeff Garzik wrote:
> Catalin Marinas wrote:
> > This patch extends the critical regions covered by lp->lock to make it
> > safer on SMP. The main failure point was the smc911x_hard_start_xmit
> > function being called from different CPUs. It was tested on the ARM SMP
> > platforms.
> > 
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >  drivers/net/smc911x.c |   25 ++++++++-----------------
> >  1 files changed, 8 insertions(+), 17 deletions(-)
> 
> applied 1-3

Thanks.

-- 
Catalin

