From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: snmp mib cleanup
Date: Sun, 21 Mar 2010 18:38:06 -0700 (PDT)
Message-ID: <20100321.183806.55843297.davem@davemloft.net>
References: <1268980566.2894.231.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54254
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753778Ab0CVBhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:37:43 -0400
In-Reply-To: <1268980566.2894.231.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Mar 2010 07:36:06 +0100

> There is no point to align or pad mibs to cache lines, they are per cpu
> allocated with a 8 bytes alignment anyway.
> This wastes space for no gain. This patch removes __SNMP_MIB_ALIGN__
> 
> Since SNMP mibs contain "unsigned long" fields only, we can relax the
> allocation alignment from "unsigned long long" to "unsigned long"
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Also applied, thanks Eric.
