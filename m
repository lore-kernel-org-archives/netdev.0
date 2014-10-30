From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: Use inner mac length when computing tunnel
 length
Date: Thu, 30 Oct 2014 19:52:57 -0400 (EDT)
Message-ID: <20141030.195257.507246809929761699.davem@davemloft.net>
References: <1414683656-26493-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.duyck@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161360AbaJ3Xw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:52:59 -0400
In-Reply-To: <1414683656-26493-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 30 Oct 2014 08:40:56 -0700

> Currently, skb_inner_network_header is used but this does not account
> for Ethernet header for ETH_P_TEB. Use skb_inner_mac_header which
> handles TEB and also should work with IP encapsulation in which case
> inner mac and inner network headers are the same.
> 
> Tested: Ran TCP_STREAM over GRE, worked as expected.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied and queued up for -stable.

Thanks everyone.
