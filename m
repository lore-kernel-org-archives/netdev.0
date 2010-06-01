From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Tue, 01 Jun 2010 15:23:23 -0700 (PDT)
Message-ID: <20100601.152323.43023787.davem@davemloft.net>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>
	<1275430054.2638.115.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53743
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757246Ab0FAWXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 18:23:13 -0400
In-Reply-To: <1275430054.2638.115.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Jun 2010 00:07:34 +0200

> IPSTATS_MIB_INADDRERRORS has a strong meaning, part of RFCS.
> 
> In this path, we simulate the routing of a virtual packet, not its
> delivery.
> 
> This should not affect IPSTATS SNMP entries.
> 
> You should use another MIB entry, say LINUX_MIB_INROUTEERRORS ?

Agreed.
