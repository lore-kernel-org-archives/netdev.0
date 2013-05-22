From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH net-next V2 1/2] xen-netback: split event
 channels support for Xen backend driver
Date: Wed, 22 May 2013 11:17:54 -0400
Message-ID: <20130522151754.GD8162@phenom.dumpdata.com>
References: <1369161310-9529-1-git-send-email-wei.liu2@citrix.com>
 <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	david.vrabel@citrix.com, ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50822 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755143Ab3EVPSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 11:18:01 -0400
Content-Disposition: inline
In-Reply-To: <1369161310-9529-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* Provide an option to disable split event channels at load time as
> + * event channels are limited resource. Split event channels are
> + * enabled by default.
> + */
> +unsigned int feature_split_event_channels = 1;
> +module_param(feature_split_event_channels, uint, 0644);

How about just 'seperate_tx_rx_irq' ? Much easier to comprehend I think?
