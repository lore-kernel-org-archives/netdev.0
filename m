From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/9] gue: Changes to ip_tunnel to support
 Generic UDP Encapsulation
Date: Thu, 17 Jul 2014 14:53:45 -0700 (PDT)
Message-ID: <20140717.145345.1627726281054820171.davem@davemloft.net>
References: <alpine.DEB.2.02.1407162055520.29792@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754216AbaGQVxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 17:53:46 -0400
In-Reply-To: <alpine.DEB.2.02.1407162055520.29792@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 16 Jul 2014 21:14:44 -0700 (PDT)

> This patch changes IP tunnel to support (secondary) encapsulation,
> Generic UDP Encapsulation. Changes include:
> 
> 1) Adding tun_hlen as the tunnel header length, encap_hlen as the
> encapsulation header length (GUE), and hlen becomes the grand total
> of these.
> 2) Added generic function to handle IOCTLs
> 3) Added IOCTLs to setup or remove encapsulation. This includes
> uapi to configure encapsulation on a tunnel.
> 4) Support to perform GUE encapsulation in ip_tunnel_xmit.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Please extend the netlink interface for creating IP tunnels rather
than adding things to the the deprecated ioctl interface.
