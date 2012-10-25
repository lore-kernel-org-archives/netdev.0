From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar_ptp: use iomem, not ioports resource tree in
 probe
Date: Wed, 24 Oct 2012 23:19:11 -0400 (EDT)
Message-ID: <20121024.231911.2065674182431820345.davem@davemloft.net>
References: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Wei.Yang@windriver.com,
	claudiu.manoil@freescale.com, timur@freescale.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60021 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615Ab2JYDTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 23:19:12 -0400
In-Reply-To: <1351092096-14811-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Wed, 24 Oct 2012 11:21:36 -0400

> From: Wei Yang <Wei.Yang@windriver.com>
> 
> When using a 36 bit dtb file, the driver complains "resource busy".
> 
> Investigating the source of the message leads one to the
> gianfar_ptp_probe function.
> 
> Since the type of the device resource requested in this function
> is IORESOURCE_MEM, it should use "iomem_resource" instead of
> "ioports_resource".
> 
> Signed-off-by: Wei Yang <Wei.Yang@windriver.com>
> Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
> Cc: Timur Tabi <timur@freescale.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks everyone.
