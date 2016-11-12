From: David Miller <davem@davemloft.net>
Subject: Re: TCP performance problems - GSO/TSO, MSS, 8139cp related
Date: Fri, 11 Nov 2016 21:52:16 -0500 (EST)
Message-ID: <20161111.215216.158904316779820587.davem@davemloft.net>
References: <20161111210500.GE1041@n2100.armlinux.org.uk>
        <1478899423.3892.7.camel@infradead.org>
        <20161111223307.GF1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@vger.kernel.org, qemu-devel@nongnu.org
To: linux@armlinux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935137AbcKLCwV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 21:52:21 -0500
In-Reply-To: <20161111223307.GF1041@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@armlinux.org.uk>
Date: Fri, 11 Nov 2016 22:33:08 +0000

> "The new buffer management algorithm provides capabilities of Microsoft
> Large-Send offload" and as yet I haven't found anything that describes
> what this is or how it works.

For once I will give Microsoft a big shout out here.

This, and everything a Microsoft networking driver interfaces to, is
_very_ much documented in extreme detail in the Microsoft NDIS
(Network Driver Interface Specification).

Microsoft's networking driver interfaces and expectations are
documented 1,000 times better than that of Linux.
