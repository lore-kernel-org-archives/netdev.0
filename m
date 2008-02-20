From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v2.6.25] gianfar: don't pass NULL dev ptr to DMA ops
Date: Wed, 20 Feb 2008 11:52:13 -0500
Message-ID: <47BC5ABD.1000103@garzik.org>
References: <1203377070-19870-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Becky Bruce <bgill@freescale.com>,
	Becky Bruce <becky.bruce@freescale.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48860 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758876AbYBTQwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:52:15 -0500
In-Reply-To: <1203377070-19870-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> From: Becky Bruce <bgill@freescale.com>
> 
> Change all dma op invocations in gianfar.c to actually pass in the
> device pointer.  Currently, the value is ignored, but it will be
> used going forward as we implement archdata for 32-bit powerpc.
> 
> Signed-off-by: Becky Bruce <becky.bruce@freescale.com>
> Acked-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)

applied


