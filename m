From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] ucc_geth: Fix arguments to dma map/unmap functions
Date: Thu, 22 May 2008 06:21:45 -0400
Message-ID: <48354939.9090109@pobox.com>
References: <1210888821-15471-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59299 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936789AbYEVKVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:21:47 -0400
In-Reply-To: <1210888821-15471-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> We were passing NULL as the device.  When we actually start supporting
> more interesting memory configurations, this will break things, so
> we proactively are fixing the bug.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/ucc_geth.c |    9 +++++----
>  1 files changed, 5 insertions(+), 4 deletions(-)

applied


