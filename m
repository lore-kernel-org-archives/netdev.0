From: David Miller <davem@davemloft.net>
Subject: Re: Signed bit field; int have_hotplug_status_watch:1
Date: Wed, 06 Apr 2011 14:43:57 -0700 (PDT)
Message-ID: <20110406.144357.186323091.davem@davemloft.net>
References: <20110403213241.GA25913@gallifrey>
	<1301905584.23887.49.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@treblig.org, virtualization@lists.linux-foundation.org,
	Jeremy.Fitzhardinge@citrix.com, konrad.wilk@oracle.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54043
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756769Ab1DFVoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:44:37 -0400
In-Reply-To: <1301905584.23887.49.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 4 Apr 2011 09:26:24 +0100

> Subject: [PATCH] xen: netback: use unsigned type for one-bit bitfield.
> 
> Fixes error from sparse:
>   CHECK   drivers/net/xen-netback/xenbus.c
> drivers/net/xen-netback/xenbus.c:29:40: error: dubious one-bit signed bitfield
> 
>         int have_hotplug_status_watch:1;
> 
> Reported-by: Dr. David Alan Gilbert <linux@treblig.org>
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>

Applied to net-next-2.6, thanks.
