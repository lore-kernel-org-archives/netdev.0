From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 1/4] net core: Add protodown support.
Date: Mon, 13 Jul 2015 14:34:32 -0700 (PDT)
Message-ID: <20150713.143432.56479578476726354.davem@davemloft.net>
References: <1436481330-4599-2-git-send-email-anuradhak@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	wkok@cumulusnetworks.com
To: anuradhak@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44254 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451AbbGMVeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 17:34:36 -0400
In-Reply-To: <1436481330-4599-2-git-send-email-anuradhak@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: anuradhak@cumulusnetworks.com
Date: Thu,  9 Jul 2015 15:35:27 -0700

> +/* proto_flags - port state information can be passed to the switch driver and
> + * used to determine the phys state of the switch port */
> +enum {
> +	IF_PROTOF_DOWN		= 1<<0	/* set switch port phys state down */
> +};

Realistically, do we really foresee any other proto flags being added in
the future?

Unless there is a strong sense that we will have some, this is
insanely overengineered with all of these bit masking capabilities and
such and nested attributes.

I'd say just do one boolean attribute and that's it.
