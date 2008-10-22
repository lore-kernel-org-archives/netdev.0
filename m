From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] smc911x: Make the driver safer on SMP
Date: Wed, 22 Oct 2008 07:01:27 -0400
Message-ID: <48FF0807.8060501@garzik.org>
References: <20081020170917.6277.21228.stgit@pc1117.cambridge.arm.com> <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40057 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbYJVLBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 07:01:30 -0400
In-Reply-To: <20081020171535.6277.50.stgit@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Catalin Marinas wrote:
> This patch extends the critical regions covered by lp->lock to make it
> safer on SMP. The main failure point was the smc911x_hard_start_xmit
> function being called from different CPUs. It was tested on the ARM SMP
> platforms.
> 
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  drivers/net/smc911x.c |   25 ++++++++-----------------
>  1 files changed, 8 insertions(+), 17 deletions(-)

applied 1-3


