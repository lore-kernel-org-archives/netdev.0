From: David Miller <davem@davemloft.net>
Subject: Re: [NET-NEXT PATCH] ixgbe: add SFP+ driver support
Date: Thu, 20 Nov 2008 00:45:19 -0800 (PST)
Message-ID: <20081120.004519.47172678.davem@davemloft.net>
References: <20081118010324.7426.80212.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35877
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753757AbYKTIpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 03:45:19 -0500
In-Reply-To: <20081118010324.7426.80212.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Nov 2008 17:03:24 -0800

> +	/* Do the sfp_timer outside of interrupt context due to the
> +	 * delays that sfp+ detection requires */
> +	schedule_work(&adapter->sfp_task);

Please fix the comment style:

	/* foo
	 * bar
	 */

not:

	/* foo
	 * bar */

Thanks,
