From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Dont add RT6_LOOKUP_F_IFACE flag if saddr
 set
Date: Thu, 22 Oct 2015 07:36:38 -0700 (PDT)
Message-ID: <20151022.073638.400620848586030811.davem@davemloft.net>
References: <1445442142-19881-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thehajime@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757631AbbJVOUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 10:20:11 -0400
In-Reply-To: <1445442142-19881-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 21 Oct 2015 08:42:22 -0700

> 741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
> adds the RT6_LOOKUP_F_IFACE flag to make device index mismatch fatal if
> oif is given. Hajime reported that this change breaks the Mobile IPv6
> use case that wants to force the message through one interface yet use
> the source address from another interface. Handle this case by only
> adding the flag if oif is set and saddr is not set.
> 
> Fixes: 741a11d9e410 ("net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set")
> Cc: Hajime Tazaki <thehajime@gmail.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
