From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] gianfar: Map head TxBD first to skip a
 wmb()
Date: Mon, 22 Feb 2016 11:04:19 -0500 (EST)
Message-ID: <20160222.110419.641505826145828651.davem@davemloft.net>
References: <1455878854-28290-2-git-send-email-claudiu.manoil@freescale.com>
	<20160221.215843.877041303205905380.davem@davemloft.net>
	<DB4PR04MB3799AF95B8C7FB8C949476496A30@DB4PR04MB379.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org
To: claudiu.manoil@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49833 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754136AbcBVQEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 11:04:23 -0500
In-Reply-To: <DB4PR04MB3799AF95B8C7FB8C949476496A30@DB4PR04MB379.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@nxp.com>
Date: Mon, 22 Feb 2016 10:14:37 +0000

> Let's take a random driver - igb, there is no wmb() between:
> tx_desc->read.buffer_addr = cpu_to_le64(dma);
> and
> /* write last descriptor with RS and EOP bits */
> cmd_type |= size | IGB_TXD_DCMD;
> tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);

It may in fact be necessary and you should contact the driver
maintainers about that.

It is absolutely inappropriate to look for exceptions to a rule
to prove that you don't have to deal with something.  Yes, bugs
or wrong handling of situations exist, but that doesn't give you
an open door to do so as well.
