From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: replace cnt & rtt with struct in
 pkts_acked()
Date: Mon, 09 May 2016 00:02:20 -0400 (EDT)
Message-ID: <20160509.000220.2229465797333792057.davem@davemloft.net>
References: <1462591714-1892853-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcEIECY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 00:02:24 -0400
In-Reply-To: <1462591714-1892853-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Fri, 6 May 2016 20:28:34 -0700

> +	if (icsk->icsk_ca_ops->pkts_acked) {
> +		struct ack_sample sample = {pkts_acked, ca_rtt_us};

Please use named initializers.

Thanks.
