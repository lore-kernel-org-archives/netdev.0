From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] Allow BATMAN to use hdlc-eth interfaces
Date: Sat, 05 Dec 2015 17:45:13 -0500 (EST)
Message-ID: <20151205.174513.2022539696324982508.davem@davemloft.net>
References: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, mareklindner@neomailbox.ch, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.net
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbbLEWpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 17:45:15 -0500
In-Reply-To: <1449173553-23784-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu,  3 Dec 2015 21:12:29 +0100

> BATMAN works over Ethernet like interfaces. hdlc-eth provides the need
> requirements. However, hdlc devices are often created as raw hdlc
> devices, which batman cannot use, and are then be transmuted into
> other types using sethdlc(1). Have the HDLC code emit
> NETDEV_*_TYPE_CHANGE events when the type changes, and have BATMAN
> react on these events.

Series applied, thanks.
