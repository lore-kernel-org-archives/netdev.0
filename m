From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Tue, 12 Oct 2010 10:40:32 -0700 (PDT)
Message-ID: <20101012.104032.71103852.davem@davemloft.net>
References: <20101011.090153.226774563.davem@davemloft.net>
	<20101011172932.GB12342@orbit.nwl.cc>
	<20101012171940.GB30613@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	johann.baudy@gnu-log.net
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45095
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757489Ab0JLRkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 13:40:10 -0400
In-Reply-To: <20101012171940.GB30613@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 12 Oct 2010 19:19:41 +0200

> Yes, like eth_type_trans does I guess.  I think we had a similar
> discussion already:
> 
> http://lists.openwall.net/netdev/2010/01/06/38
> 
> Summary: if we want to make the protocol field have the correct
> value for this case we need to make it work for other
> transports not just for ethernet.

Right, so for now we should just allow 4-byte larger
than MTU TX packets, as long as the device is ethernet
and can handle VLANs properly.
