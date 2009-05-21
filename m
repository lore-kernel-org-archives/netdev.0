From: David Miller <davem@davemloft.net>
Subject: Re: [oops] with FIB_TRIE [PATCH]
Date: Thu, 21 May 2009 15:21:12 -0700 (PDT)
Message-ID: <20090521.152112.52289614.davem@davemloft.net>
References: <18965.10920.161382.237618@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	andrei.popa@i-neo.ro
To: robert@robur.slu.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42379
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755081AbZEUWVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 18:21:13 -0400
In-Reply-To: <18965.10920.161382.237618@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Olsson <robert@robur.slu.se>
Date: Thu, 21 May 2009 12:19:20 +0200

>  It seems we can fix this by disabling preemption while we re-balance the 
>  trie. This is with the CONFIG_CLASSIC_RCU. It's been stress-tested at high 
>  loads continuesly taking a full BGP table up/down via iproute -batch.
>  A patch is below.
> 
>  Note. fib_trie is not updated for CONFIG_PREEMPT_RCU
>  
> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Applied, thanks Robert.
