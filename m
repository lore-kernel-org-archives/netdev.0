From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] vxlan: Don't use UDP socket for
 transmit
Date: Sat, 24 Jan 2015 23:16:08 -0800 (PST)
Message-ID: <20150124.231608.472694661359785983.davem@davemloft.net>
References: <1421781785-24557-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jesse@nicira.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbbAYHQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 02:16:09 -0500
In-Reply-To: <1421781785-24557-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 20 Jan 2015 11:23:03 -0800

> UDP socket is not pertinent to transmit for UDP tunnels, checksum
> enablement can be done without a socket. This patch set eliminates
> reference to a socket in udp_tunnel_xmit functions and in VXLAN
> transmit.
> 
> Also, make GBP, RCO, can CSUM6_RX flags visible to receive socket
> and only match these for shareable socket.
> 
> v2: Fix geneve to call udp_tunnel_xmit with good arguments.

Series applied, thanks Tom.
