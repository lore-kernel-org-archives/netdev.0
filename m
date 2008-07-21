From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 18:03:04 -0700 (PDT)
Message-ID: <20080720.180304.51601407.davem@davemloft.net>
References: <20080720.104411.81744468.davem@davemloft.net>
	<alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jmorris@namei.org, kaber@trash.net
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45789
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754956AbYGUBDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:03:05 -0400
In-Reply-To: <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 20 Jul 2008 17:54:04 -0700 (PDT)

> On Sun, 20 Jul 2008, David Miller wrote:
> > 
> > Hello Linus.  This is the main networking merge for 2.6.27
> 
> Grr. And I quote:
> 
> 	  Security table (IP_NF_SECURITY) [Y/n/?] (NEW) ?
> 	
> 	This option adds a `security' table to iptables, for use
> 	with Mandatory Access Control (MAC) policy.
> 	
> 	If unsure, say N.
> 
> why the heck does this new config option apparently default to 'Y'? It's a 
> new option, so no old users can need it, and the docs even say you should 
> say 'N' unless you know what you're doing.
> 
> (Same issue with the IPv6 version).
> 
> Don't do this.

James/Patrick please fix this.

Thanks.
