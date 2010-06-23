From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: fix SNMP_ADD_STATS()
Date: Wed, 23 Jun 2010 11:48:31 -0700 (PDT)
Message-ID: <20100623.114831.71094742.davem@davemloft.net>
References: <1277289123.2469.278.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41430
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751794Ab0FWSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 14:48:19 -0400
In-Reply-To: <1277289123.2469.278.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Jun 2010 12:32:03 +0200

> commit aa2ea0586d9d (tcp: fix outsegs stat for TSO segments) incorrectly
> assumed SNMP_ADD_STATS() was used from BH context.
> 
> Fix this using mib[!in_softirq()] instead of mib[0]
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
