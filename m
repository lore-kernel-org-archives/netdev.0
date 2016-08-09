From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] strparser: Stream parser for messages
Date: Tue, 09 Aug 2016 16:14:56 -0700 (PDT)
Message-ID: <20160809.161456.360128105313384145.davem@davemloft.net>
References: <1470086929-3666623-1-git-send-email-tom@herbertland.com>
	<1470086929-3666623-2-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36000 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521AbcHIXO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 19:14:57 -0400
In-Reply-To: <1470086929-3666623-2-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 1 Aug 2016 14:28:47 -0700

> +/* Lower lock held */
> +void strp_parser_err(struct strparser *strp, int err, read_descriptor_t *desc)
> +{
> +	desc->error = err;
> +	kfree_skb(strp->rx_skb_head);
> +	strp->rx_skb_head = NULL;
> +	strp_abort_rx_strp(strp, err);
> +}

Unused outside of this file, please mark "static".

> +void strp_queue_work(struct strparser *strp)
> +{
> +	queue_work(strp_wq, &strp->rx_work);
> +}

Completely unused, please remove.

Thanks.
