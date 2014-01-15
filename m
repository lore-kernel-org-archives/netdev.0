From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] openvswitch: Pad OVS_PACKET_ATTR_PACKET if
 linear copy was performed
Date: Tue, 14 Jan 2014 19:03:54 -0800 (PST)
Message-ID: <20140114.190354.1862604735799307127.davem@davemloft.net>
References: <20140114161640.GA24121@casper.infradead.org>
	<20140114161911.GB24121@casper.infradead.org>
	<20140114162749.GC24121@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@citrix.com, tgraf@redhat.com, jesse@nicira.com,
	dev@openvswitch.org, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54668 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664AbaAODDy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 22:03:54 -0500
In-Reply-To: <20140114162749.GC24121@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 14 Jan 2014 16:27:49 +0000

> While the zerocopy method is correctly omitted if user space
> does not support unaligned Netlink messages. The attribute is
> still not padded correctly as skb_zerocopy() will not ensure
> padding and the attribute size is no longer pre calculated
> though nla_reserve() which ensured padding previously.
> 
> This patch applies appropriate padding if a linear data copy
> was performed in skb_zerocopy().
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: initialize padding to 0's

Jesse do you want to queue this up or should I apply it directly?

Thanks.
