From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking for 2.6.28
Date: Sat, 11 Oct 2008 10:57:29 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810111057020.3402@nehalem.linux-foundation.org>
References: <20081010.144921.115563930.davem@davemloft.net> <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49883 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932552AbYJKR5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:57:32 -0400
In-Reply-To: <alpine.LFD.2.00.0810110941330.3402@nehalem.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Sat, 11 Oct 2008, Linus Torvalds wrote:
> 
> On Fri, 10 Oct 2008, David Miller wrote:
> > 
> > Here are the queued up networking changes for the 2.6.28 merge window.
> 
> This generates _tons_ of new warnings for me:

And apparently errors for others:

 net/netfilter/ipvs/ip_vs_xmit.c: In function 'ip_vs_tunnel_xmit':
 net/netfilter/ipvs/ip_vs_xmit.c:616: error: implicit declaration of function 'ip_select_ident'

some other config-dependent breakage.

			Linus
