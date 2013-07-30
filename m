From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: set correct tx_queue_len for bond_dev
Date: Tue, 30 Jul 2013 00:34:03 -0700 (PDT)
Message-ID: <20130730.003403.299786235452826263.davem@davemloft.net>
References: <51F7694A.1060703@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58455 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519Ab3G3HeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:34:04 -0400
In-Reply-To: <51F7694A.1060703@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 30 Jul 2013 15:20:42 +0800

> With htb, sch->limit is set from bond_dev->tx_queue_len which
> is initialized to 0 in bond_setup.

This is intentional, software devices should not queue TX
packets.

You can only use the packet scheduler with hardware devices.
