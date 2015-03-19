From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tipc: fix build issue when building without IPv6
Date: Thu, 19 Mar 2015 16:06:58 -0400 (EDT)
Message-ID: <20150319.160658.1294624225284354605.davem@davemloft.net>
References: <20150319.150433.850095478975909930.davem@davemloft.net>
	<1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, erik.hugne@ericsson.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49994 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751115AbbCSUHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 16:07:05 -0400
In-Reply-To: <1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 19 Mar 2015 16:47:58 -0300

> We can't directly call ipv6_sock_mc_join() but should use the stub
> instead and protect it around IS_ENABLED.
> 
> Fixes: d0f91938bede ("tipc: add ip/udp media type")
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

This works better, applied, thanks.
