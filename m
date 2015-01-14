From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb4: Update ipv6 address handling api
Date: Wed, 14 Jan 2015 16:29:22 -0500 (EST)
Message-ID: <20150114.162922.1789342830064884975.davem@davemloft.net>
References: <1421202516-13862-1-git-send-email-anish@chelsio.com>
	<1421202516-13862-2-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, kxie@chelsio.com,
	deepak.s@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45519 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbbANV3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 16:29:25 -0500
In-Reply-To: <1421202516-13862-2-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 13 Jan 2015 18:28:35 -0800

> +	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
> +			FW_CMD_REQUEST_F | FW_CMD_WRITE_F);

Please indent this properly, the second line should start at the first
column after the openning parenthesis of htonl().

> +	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
> +			FW_CMD_REQUEST_F | FW_CMD_READ_F);

Likewise.

> +	ctbl = t4_alloc_mem(sizeof(*ctbl) +
> +				clipt_size*sizeof(struct list_head));

Likewise.
