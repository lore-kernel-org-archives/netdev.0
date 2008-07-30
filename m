From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.27-rc1]: fix NE2000 linkage error
Date: Wed, 30 Jul 2008 17:15:22 -0400
Message-ID: <4890D9EA.5080401@garzik.org>
References: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33652 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758221AbYG3VPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 17:15:30 -0400
In-Reply-To: <200807301144.m6UBitOG022822@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson wrote:
> Trying to build with CONFIG_NE2000=m fails with:
> 
>   scripts/mod/modpost   -o /tmp/tmp/linux-2.6.27-rc1/Module.symvers    -S     -s
> ERROR: "NS8390_init" [drivers/net/ne.ko] undefined!
> 
> This is because the split of 8390 into pausing and non-pausing
> versions was incompletely propagated to ne.c. This fixes it.
> 
> Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>

actually, I take that back, I still needed a bit of this.  thanks


