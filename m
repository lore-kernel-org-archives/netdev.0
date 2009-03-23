From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: fix unaligned memory access in tcp_sack
Date: Sun, 22 Mar 2009 21:17:30 -0700 (PDT)
Message-ID: <20090322.211730.224794112.davem@davemloft.net>
References: <878wmx3pfk.fsf@netris.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: mhw@netris.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47532
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750774AbZCWERn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 00:17:43 -0400
In-Reply-To: <878wmx3pfk.fsf@netris.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mark H. Weaver" <mhw@netris.org>
Date: Sun, 22 Mar 2009 23:09:51 -0400

> This patch fixes an unaligned memory access in tcp_sack while reading
> sequence numbers from TCP selective acknowledgement options.  Prior to
> applying this patch, upstream linux-2.6.27.20 was occasionally
> generating messages like this on my sparc64 system:
> 
>   [54678.532071] Kernel unaligned access at TPC[6b17d4] tcp_packet+0xcd4/0xd00
> 
> More details provided upon request.  Apologies in advance if I've sent
> this to the wrong place or not followed proper procedures.

Acked-by: David S. Miller <davem@davemloft.net>
