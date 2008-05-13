From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] gianfar: Fix a bug where the pointer never moves
 for dma_unmap...
Date: Tue, 13 May 2008 01:16:01 -0400
Message-ID: <48292411.4050102@pobox.com>
References: <1210184455-28477-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49343 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754651AbYEMFQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 01:16:04 -0400
In-Reply-To: <1210184455-28477-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> The loop that unmaps all of the TX Buffer Descriptors never actually
> moves the txbd pointer, so we were just repeatedly unmapping the first one.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar.c |    2 ++

applied


