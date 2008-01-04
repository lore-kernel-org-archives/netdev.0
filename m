From: David Miller <davem@davemloft.net>
Subject: Re: [ICMP]: Avoid sparse warnings in net/ipv4/icmp.c
Date: Thu, 03 Jan 2008 21:26:10 -0800 (PST)
Message-ID: <20080103.212610.263261100.davem@davemloft.net>
References: <477DC304.40508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752237AbYADF0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 00:26:11 -0500
In-Reply-To: <477DC304.40508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 04 Jan 2008 06:24:20 +0100

>    CHECK   net/ipv4/icmp.c
> net/ipv4/icmp.c:249:13: warning: context imbalance in 'icmp_xmit_unlock' - 
> unexpected unlock
> net/ipv4/icmp.c:376:13: warning: context imbalance in 'icmp_reply' - different 
> lock contexts for basic block
> net/ipv4/icmp.c:430:6: warning: context imbalance in 'icmp_send' - different 
> lock contexts for basic block
> 
> Solution is to declare icmp_xmit_unlock() as __inline__ (similar with 
> icmp_xmit_lock())

Please use "inline" instead of "__inline__".  If other stuff
uses __inline__ in that file, feel free to fix it up too.
