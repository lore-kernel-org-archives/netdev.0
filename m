From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Remove unused dst_pid field in netlink_skb_parms
Date: Mon, 27 Nov 2006 09:26:26 -0800 (PST)
Message-ID: <20061127.092626.63729858.davem@davemloft.net>
References: <20061127090238.GU8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38546
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1758457AbWK0R0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 12:26:23 -0500
To: tgraf@suug.ch
In-Reply-To: <20061127090238.GU8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Mon, 27 Nov 2006 10:02:38 +0100

> The destination PID is passed directly to netlink_unicast()
> respectively netlink_multicast().
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Nothing but assignments to that thing :-)  Good catch,
applied, thanks Thomas.
