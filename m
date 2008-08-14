From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] gianfar: Call gfar_halt_nodisable() from gfar_halt().
Date: Thu, 14 Aug 2008 04:28:38 -0400
Message-ID: <48A3ECB6.8000601@pobox.com>
References: <20080812201046.GC27956@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41403 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978AbYHNI2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:28:42 -0400
In-Reply-To: <20080812201046.GC27956@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> gfar_halt() was factored out into halting and disabling by commit
> d87eb12785c14de1586e3bad86ca2c0991300339, as the suspend() method
> only wants to do the former.  However, the call to gfar_halt_nodisable()
> from gfar_halt() apparently got lost during the patch respin process.
> 
> This adds it back.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  drivers/net/gianfar.c |    6 ++----
>  1 files changed, 2 insertions(+), 4 deletions(-)

applied


