From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] bnx2x: support classification config query
Date: Tue, 06 Dec 2011 00:46:29 -0500 (EST)
Message-ID: <20111206.004629.1477080329086805790.davem@davemloft.net>
References: <1323150288-28153-1-git-send-email-mchan@broadcom.com>
	<1323150288-28153-2-git-send-email-mchan@broadcom.com>
	<1323150288-28153-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab1LFFqc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:46:32 -0500
In-Reply-To: <1323150288-28153-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Mon, 5 Dec 2011 21:44:47 -0800

> +	/* traverse list */
> +	list_for_each_entry(pos, &o->head, link)
> +	{

Put openning "{" at end of list_for_each_entry(), rather than
on a new line.

> +		if ((counter < n)) {

Excessive parenthesis, remove.

> +			memcpy(next + MAC_LEADING_ZERO_CNT,
> +				  pos->u.mac.mac, ETH_ALEN);

Paremeters on subsequent lines don't line up properly.

> +			next = buf + counter * ALIGN(ETH_ALEN,
> +							   sizeof(u32));

Likewise.

> +			DP(BNX2X_MSG_SP, "copied element number "
> +				   "%d to address %p element was "
> +				   "%pM\n", counter, next, pos->u.mac.mac);

Likewise.

> +	int (*get_n_elements)(struct bnx2x *bp,
> +			 struct bnx2x_vlan_mac_obj *o,
> +			 int n,
> +			 u8 *buf);
> +

Likewise.

Sigh.

Definitely a new-comer wrote this code, but I know more experienced hands
reviewed it, therefore I am disappointed.
