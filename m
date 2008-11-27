From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
 driver v2
Date: Thu, 27 Nov 2008 00:17:48 -0800 (PST)
Message-ID: <20081127.001748.204325827.davem@davemloft.net>
References: <cover.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45870
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751939AbYK0IRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 03:17:48 -0500
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Wed, 26 Nov 2008 14:40:19 -0800

> Changes since v1:
> 
>  - (Stephen Hemminger) don't use bitfields in struct wimax_dev 
> 
>  - (Stephen Hemminger) don't use the interface name for the generic
>    netlink family, as it might change on if rename. Change to use the
>    interface index.
> 
>  - (David Miller) move the WiMAX stack to net/wimax
> 
>  - misc checkpatch fixes, kconfig cleanups. 
> 
>  - use DEFINE_SPINLOCK

I'm fine with this, so feel free to merge this stuff in via
the USB stack (due to the dependencies there).

Thanks!
