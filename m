From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Tue, 08 Jul 2014 15:26:55 -0700 (PDT)
Message-ID: <20140708.152655.619472955292197550.davem@davemloft.net>
References: <1404561288-11720-1-git-send-email-ezequiel.garcia@free-electrons.com>
	<1404561288-11720-2-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	jason@lakedaemon.net, mw@semihalf.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755377AbaGHW04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 18:26:56 -0400
In-Reply-To: <1404561288-11720-2-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Sat,  5 Jul 2014 08:54:46 -0300

> +module_param(rxq_number, int, S_IRUGO);
> +module_param(txq_number, int, S_IRUGO);

Please don't use module parameters (undocumented ones at that) for things
like this.

Instead, use or create standard interfaces which other drivers can use as
well, so that the user interface is consistent for setting things of this
nature regardless of device type.

Thanks.
