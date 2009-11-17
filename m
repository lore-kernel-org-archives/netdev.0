From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Mon, 16 Nov 2009 19:10:54 -0800 (PST)
Message-ID: <20091116.191054.131722163.davem@davemloft.net>
References: <4AFBD911.6000900@gmail.com>
	<4AFCE273.7010901@gmail.com>
	<20091116083905.634b8f56@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, eric.dumazet@gmail.com,
	therbert@google.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53684
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085AbZKQDKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 22:10:38 -0500
In-Reply-To: <20091116083905.634b8f56@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 16 Nov 2009 08:39:05 -0800

> My $.02 is that receive packet steering RPS should be done generically at
> receive layer. Then all the CPU, mapping and configuration issues can be
> done once, not just for IFB, Bridge, VLAN, ... The number of users of IFB
> is small, and setup is complex. Steering packets in IFB is optimizing only
> a rarely used corner.
> 
> Layered link services like IFB need to be multi-threaded lockless to maintain
> the advantages of multi-queue and RPS.

You're probably right.
