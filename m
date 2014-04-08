From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: add a sysctl to reflect the fwmark on replies
Date: Mon, 07 Apr 2014 20:06:38 -0400 (EDT)
Message-ID: <20140407.200638.1315731010863669193.davem@davemloft.net>
References: <1396915131-20353-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg, hannes@stressinduktion.org
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbaDHAGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 20:06:39 -0400
In-Reply-To: <1396915131-20353-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Tue,  8 Apr 2014 08:58:51 +0900

> Kernel-originated IP packets that have no user socket associated
> with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
> are emitted with a mark of zero. Add a sysctl to make them have
> the same mark as the packet they are replying to.
> 
> This allows an administrator that wishes to do so to use
> mark-based routing, firewalling, etc. for these replies by
> marking the original packets inbound.
> 
> Tested using user-mode linux:
>  - ICMP/ICMPv6 echo replies and errors.
>  - TCP RST packets (IPv4 and IPv6).
> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

This is a new feature, which should be targetted at net-next, which
is closed at this time.

Please resubmit this when the net-next tree opens back up, and
properly tag your subject line with "net-next" so that it is clear
what tree your change is targetted at.

Thanks.
