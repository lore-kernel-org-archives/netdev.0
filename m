From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Update ucc_geth.c for new workqueue structure
Date: Thu, 18 Jan 2007 12:04:10 -0500
Message-ID: <45AFA88A.5080806@garzik.org>
References: <11683674984043-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44511 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060AbXARREM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 12:04:12 -0500
To: timur@freescale.com
In-Reply-To: <11683674984043-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

timur@freescale.com wrote:
> From: Timur Tabi <timur@freescale.com>
> 
> The workqueue interface changed with David Howell's patch on 11/22/2006
> (SHA 65f27f38446e1976cc98fd3004b110fedcddd189).  Several drivers were
> updated with that patch to handle the new interface, but ucc_geth.c
> was not one of them.  This patch updates ucc_geth.c to support the new
> model.
> 
> A compiler warning in set_mac_addr() was also fixed.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
> 
> ---
>  drivers/net/ucc_geth.c |   12 +++++++-----
>  1 files changed, 7 insertions(+), 5 deletions(-)

applied


