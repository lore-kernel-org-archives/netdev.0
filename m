From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Mon, 28 Apr 2008 11:02:29 +0400
Message-ID: <48157685.1040709@openvz.org>
References: <20080427231411.GA5261@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56447 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763221AbYD1HFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 03:05:47 -0400
In-Reply-To: <20080427231411.GA5261@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Lastly, in /proc/net/snmp on lists, I find:
> 
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> Ip: 2 64 12771 0 0 0 0 0 5159 6262 9 0 2 8172 1363 2 922 0 5520

Can you please also show the /proc/net/netstat contents - I'm interested
in IpExt statistics.

Thanks,
Pavel
