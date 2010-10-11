From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_packet: account for VLAN when checking packet size
Date: Mon, 11 Oct 2010 09:01:53 -0700 (PDT)
Message-ID: <20101011.090153.226774563.davem@davemloft.net>
References: <20101011131500.GA12342@orbit.nwl.cc>
	<1286803522-16478-1-git-send-email-phil@nwl.cc>
	<1286805782.2737.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: phil@nwl.cc, netdev@vger.kernel.org, johann.baudy@gnu-log.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754562Ab0JKQBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:01:31 -0400
In-Reply-To: <1286805782.2737.25.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Oct 2010 16:03:02 +0200

> If we dont test ETH_P_8021Q protocol here, we allow sending 1504 bytes
> frames for MTU=1500
> 
> Should we really care ?
> 
> If not, just do
> 
> reserve = dev->hard_header_len + VLAN_HLEN;

Thats a good point, I think we need to validate the SKB protocol
field.
