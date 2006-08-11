From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] llc: multicast receive device match
Date: Thu, 10 Aug 2006 17:35:15 -0700 (PDT)
Message-ID: <20060810.173515.115932577.davem@davemloft.net>
References: <20060803100558.72ff1863@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57238
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932371AbWHKAfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 20:35:10 -0400
To: shemminger@osdl.org
In-Reply-To: <20060803100558.72ff1863@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 3 Aug 2006 10:05:58 -0700

> Fix from Aji_Srinivas@emc.com, STP packets are incorrectly received on all
> LLC datagram sockets, whichever interface they are bound to. 
> The llc_sap datagram receive logic sends packets with a unicast destination 
> MAC to one socket bound to that SAP and MAC, and multicast packets to all sockets
> bound to that SAP. STP packets are multicast, and we do need to know
> on which interface they were received.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Looks correct, I will apply this.

Thanks a lot.
