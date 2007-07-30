From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gfar: Fix modpost warning
Date: Mon, 30 Jul 2007 15:48:25 -0400
Message-ID: <46AE4089.5060602@garzik.org>
References: <Pine.LNX.4.64.0707260051550.30449@blarg.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51878 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763393AbXG3Ts2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:48:28 -0400
In-Reply-To: <Pine.LNX.4.64.0707260051550.30449@blarg.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> Fix the following modpost warning:
> 
> WARNING: vmlinux.o(.init.text+0x1aa6c): Section mismatch: reference to .exit.text:gfar_mdio_exit (between 'gfar_init' and 'gfar_mdio_init')
> 
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> ---
>  drivers/net/gianfar_mii.c |    2 +-
>  drivers/net/gianfar_mii.h |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

applied


