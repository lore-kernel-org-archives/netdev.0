From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: SNMP_UPD_PO_STATS_BH() always called from softirq
Date: Mon, 21 Mar 2011 18:13:03 -0700 (PDT)
Message-ID: <20110321.181303.232750003.davem@davemloft.net>
References: <1300707055.2884.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754976Ab1CVBMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:12:25 -0400
In-Reply-To: <1300707055.2884.144.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 21 Mar 2011 12:30:55 +0100

> We dont need to test if we run from softirq context, we definitely are.
> 
> This saves few instructions in ip_rcv() & ip_rcv_finish()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
