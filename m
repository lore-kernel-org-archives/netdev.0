From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: l3mdev: Add master device lookup by
 index
Date: Sun, 22 Nov 2015 12:23:59 -0500 (EST)
Message-ID: <20151122.122359.2247708943529789130.davem@davemloft.net>
References: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbKVRYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 12:24:01 -0500
In-Reply-To: <1447965121-2345-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 19 Nov 2015 12:32:00 -0800

> Add helper to lookup master index given a device index.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

I don't like where this is going.

sk->sk_bound_dev_if is for device bindings which the user has
explicitly asked for.

We should never, therefore, automatically set it without the user's
consent.

I'm not applying these patches, sorry.
