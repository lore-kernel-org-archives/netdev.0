From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 2/3] forcedeth: disable msix
Date: Fri, 23 Feb 2007 15:20:05 -0500
Message-ID: <20070223202004.GA16359@gospo.rdu.redhat.com>
References: <45DAB2A0.2020004@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932634AbXBWUUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Feb 2007 15:20:35 -0500
Content-Disposition: inline
In-Reply-To: <45DAB2A0.2020004@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 03:34:40AM -0500, Ayaz Abdulla wrote:
> There seems to be an issue when both MSI-X is enabled and NAPI is 
> configured. This patch disables MSI-X until the issue is root caused.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 

> --- orig/drivers/net/forcedeth.c	2007-02-20 03:29:04.000000000 -0500
> +++ new/drivers/net/forcedeth.c	2007-02-20 03:29:33.000000000 -0500
> @@ -839,7 +839,7 @@
>  	NV_MSIX_INT_DISABLED,
>  	NV_MSIX_INT_ENABLED
>  };
> -static int msix = NV_MSIX_INT_ENABLED;
> +static int msix = NV_MSIX_INT_DISABLED;
>  
>  /*
>   * DMA 64bit


Ayaz,

Can you elaborate on symptoms that would make one want to use this
patch?

-andy


