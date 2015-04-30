From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Thu, 30 Apr 2015 16:35:17 -0400 (EDT)
Message-ID: <20150430.163517.1578100484032071517.davem@davemloft.net>
References: <1430346822-13103-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
	jasowang@redhat.com
To: kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbbD3UfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 16:35:19 -0400
In-Reply-To: <1430346822-13103-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Wed, 29 Apr 2015 15:33:42 -0700

> @@ -772,19 +773,21 @@ static inline int netvsc_send_pkt(
>  	if (packet->page_buf_cnt) {
>  		pgbuf = packet->cp_partial ? packet->page_buf +
>  			packet->rmsg_pgcnt : packet->page_buf;
> -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
>  						  pgbuf,

You have to fix the indentation of the arguments if you are going to change
the column where the openning parenthesis occurs on the first line.
