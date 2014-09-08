From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix GRE RX to use skb_transport_header for GRE
 header offset
Date: Mon, 08 Sep 2014 15:23:17 -0700 (PDT)
Message-ID: <20140908.152317.2003775788913404988.davem@davemloft.net>
References: <1410190152-7396-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754999AbaIHWXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 18:23:21 -0400
In-Reply-To: <1410190152-7396-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon,  8 Sep 2014 08:29:12 -0700

> GRE assumes that the GRE header is at skb_network_header +
> ip_hrdlen(skb). It is more general to use skb_transport_header
> and this allows the possbility of inserting additional header
> between IP and GRE (which is what we will done in Generic UDP
> Encapsulation for GRE).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
