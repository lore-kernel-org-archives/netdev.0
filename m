From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Add RT6_LOOKUP_F_IFACE flag if oif is set
Date: Tue, 29 Sep 2015 15:01:27 -0700 (PDT)
Message-ID: <20150929.150127.1467318386564675351.davem@davemloft.net>
References: <1443460333-23302-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@linux-dude.de,
	yoshfuji@linux-ipv6.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59525 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbbI2WB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:01:28 -0400
In-Reply-To: <1443460333-23302-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 28 Sep 2015 10:12:13 -0700

> Wolfgang reported that IPv6 stack is ignoring oif in output route lookups:
 ...
> The stack does consider the oif but a mismatch in rt6_device_match is not
> considered fatal because RT6_LOOKUP_F_IFACE is not set in the flags.
> 
> Cc: Wolfgang Nothdurft <netdev@linux-dude.de>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thank you.
