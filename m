From: David Miller <davem@davemloft.net>
Subject: Re: [IPv6] iflink: Convert IPv6's RTM_GETLINK to use the new
 netlink api
Date: Tue, 14 Nov 2006 19:54:35 -0800 (PST)
Message-ID: <20061114.195435.115640025.davem@davemloft.net>
References: <20061114142714.GR8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18151
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753757AbWKODyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 22:54:33 -0500
To: tgraf@suug.ch
In-Reply-To: <20061114142714.GR8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 14 Nov 2006 15:27:14 +0100

> By replacing the current method of exporting the device configuration
> which included allocating a temporary buffer, copying ipv6_devconf
> into it and copying that buffer into the message with a method that
> uses nla_reserve() allowing to copy the device configuration directly
> into the skb data buffer, a GFP_ATOMIC allocation could be removed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
