From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 2.6.25] netns: struct net content re-work (v3)
Date: Tue, 11 Dec 2007 04:19:26 -0800 (PST)
Message-ID: <20071211.041926.127612929.davem@davemloft.net>
References: <20071211115507.GA9947@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752131AbXLKMT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 07:19:26 -0500
In-Reply-To: <20071211115507.GA9947@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Tue, 11 Dec 2007 14:55:07 +0300

> Recently David Miller and Herbert Xu pointed out that struct net becomes
> overbloated and un-maintainable. There are two solutions:
> - provide a pointer to a network subsystem definition from struct net.
>   This costs an additional dereferrence
> - place sub-system definition into the structure itself. This will speedup
>   run-time access at the cost of recompilation time
> 
> The second approach looks better for us. Other sub-systems will follow.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Daniel Lezcano <dlezcano@fr.ibm.com>

Applied.
