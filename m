From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 12/19] qlcnic: update irq management routines
Date: Thu, 20 Sep 2012 18:32:31 -0400 (EDT)
Message-ID: <20120920.183231.24638843071384472.davem@davemloft.net>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
	<1348098373-20745-13-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab2ITWcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 18:32:33 -0400
In-Reply-To: <1348098373-20745-13-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Wed, 19 Sep 2012 19:46:06 -0400

> +		if (QLCNIC_IS_83XX(adapter) &&
> +				(adapter->flags & QLCNIC_MSIX_ENABLED)) {

This is not indented properly.  The first character on the second
line should be at the first column after the openning parenthesis
on the first line.

> +			for (ring = 0; ring < adapter->max_drv_tx_rings;
> +								ring++) {

Same problem here.

> +			for (ring = 0; ring < adapter->max_drv_tx_rings;
> +				 ring++) {

And here as well.
