From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sfc: Fix polling for slow MCDI operations
Date: Wed, 13 Jan 2010 17:15:51 -0800 (PST)
Message-ID: <20100113.171551.103071659.davem@davemloft.net>
References: <1263393265.2797.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58599
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751809Ab0ANBPm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:15:42 -0500
In-Reply-To: <1263393265.2797.4.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Jan 2010 14:34:25 +0000

> When the interface is down and we are using polled mode for MCDI
> operations, we busy-wait for completion for approximately 1 jiffy
> using udelay() and then back off to schedule().  But the completion
> will not wake the task, since we are using polled mode!  We must use
> schedule_timeout_uninterruptible() instead.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
