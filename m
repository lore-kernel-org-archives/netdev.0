From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TPROXY] fill struct flowi->flags in udp_sendmsg()
Date: Thu, 20 Nov 2008 01:07:32 -0800 (PST)
Message-ID: <20081120.010732.232834840.davem@davemloft.net>
References: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bazsi@balabit.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35380
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbYKTJHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:07:32 -0500
In-Reply-To: <6afd3db7f90a6e8637f3f97607422abb8997c64b.1227023129.git.bazsi@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balazs Scheidler <bazsi@balabit.hu>
Date: Tue, 18 Nov 2008 16:26:32 +0100

>     udp_sendmsg() didn't fill struct flowi->flags, which means that
>     the route lookup would fail for non-local IPs even if the
>     IP_TRANSPARENT sockopt was set.
> 
>     This prevents sendto() to work properly for UDP sockets, whereas
>     bind(foreign-ip) + connect() + send() worked fine.
> 
> Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>

Applied to net-2.6
