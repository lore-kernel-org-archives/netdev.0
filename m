From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv6: corrects sended rtnetlink message
Date: Tue, 21 Aug 2007 00:20:58 -0700 (PDT)
Message-ID: <20070821.002058.102575162.davem@davemloft.net>
References: <20070815143322.GA25640@wq.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: milon@wq.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752045AbXHUHU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 03:20:59 -0400
In-Reply-To: <20070815143322.GA25640@wq.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Milan Kocian <milon@wq.cz>
Date: Wed, 15 Aug 2007 16:33:22 +0200

> ipv6 sends a RTM_DELLINK netlink message on both events: NETDEV_DOWN,
> NETDEV_UNREGISTER. Corrected by sending RTM_NEWLINK on NETDEV_DOWN event
> and RTM_DELLINK on NETDEV_UNREGISTER event.

Why would we indicate that a new device has appeared on NETDEV_DOWN?

I don't see any sense in saying "RTM_NEWLINK" for a removal, it's
for additions.
