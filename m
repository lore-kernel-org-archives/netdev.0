From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 11/19] qlcnic: sysfs interface routine updates
Date: Thu, 20 Sep 2012 18:31:06 -0400 (EDT)
Message-ID: <20120920.183106.654311916325703532.davem@davemloft.net>
References: <1348098373-20745-1-git-send-email-sony.chacko@qlogic.com>
	<1348098373-20745-12-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	himanshu.madhani@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756267Ab2ITWbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 18:31:08 -0400
In-Reply-To: <1348098373-20745-12-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Wed, 19 Sep 2012 19:46:05 -0400

> +			if (QLCNIC_IS_82XX(adapter)) {
> +				ret = QLC_DEV_GET_DRV(op_mode, pci_func);
> +			}

Don't use curly braces for a single line basic block.
