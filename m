From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2] altera tse: add support for fixed-links.
Date: Thu, 23 Apr 2015 14:57:03 -0400 (EDT)
Message-ID: <20150423.145703.1005208935486638869.davem@redhat.com>
References: <1429633945-30463-1-git-send-email-ennoerlangen@gmail.com>
	<1429708942-7961-1-git-send-email-ennoerlangen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vbridger@opensource.altera.com, netdev@vger.kernel.org,
	nios2-dev@lists.rocketboards.org, ennoerlangen@gmail.com
To: ennoerlangen@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030531AbbDWS5Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 14:57:16 -0400
In-Reply-To: <1429708942-7961-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <ennoerlangen@googlemail.com>
Date: Wed, 22 Apr 2015 15:22:22 +0200

> +		/* check if a fixed-link is defined in device-tree */
> +		if (of_phy_is_fixed_link(priv->device->of_node)) {
> +			if (of_phy_register_fixed_link(priv->device->of_node)
> +			    < 0) {

You should store the return value of of_phy_register_fixed_link() and return
that as the error code when it fails.
