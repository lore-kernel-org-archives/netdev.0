From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] TCP: update ip_local_port_range documentation
Date: Tue, 03 Apr 2012 00:54:28 -0400 (EDT)
Message-ID: <20120403.005428.1951197638640326467.davem@davemloft.net>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: fernando@intellilink.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58195 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab2DCEyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 00:54:35 -0400
In-Reply-To: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fernando@intellilink.co.jp
Date: Tue,  3 Apr 2012 09:48:40 +0900

> +	These two numbers determine the number of active connections
> +	which this system can issue simultaneously to systems not
> +	supporting TCP extensions (timestamps).

This paragraph is false altogether, it's only true if we have
one configured IP address.

I'd remove it entirely, it doesn't help anyone and just adds
confusion.
