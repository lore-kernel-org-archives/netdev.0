From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 11:12:38 -0700 (PDT)
Message-ID: <20081011.111238.214770735.davem@davemloft.net>
References: <20081010.144921.115563930.davem@davemloft.net>
	<alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
	<alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41737
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762249AbYJKSNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 14:13:02 -0400
In-Reply-To: <alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 11 Oct 2008 10:57:29 -0700 (PDT)

> On Sat, 11 Oct 2008, Linus Torvalds wrote:
> > 
> > On Fri, 10 Oct 2008, David Miller wrote:
> > > 
> > > Here are the queued up networking changes for the 2.6.28 merge window.
> > 
> > This generates _tons_ of new warnings for me:
> 
> And apparently errors for others:
> 
>  net/netfilter/ipvs/ip_vs_xmit.c: In function 'ip_vs_tunnel_xmit':
>  net/netfilter/ipvs/ip_vs_xmit.c:616: error: implicit declaration of function 'ip_select_ident'
> 
> some other config-dependent breakage.

I'll fix this, seems to be just a missing include.

Thanks.

