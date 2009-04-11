From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bonding: fix zero address hole bug in arp_ip_target
 list
Date: Sat, 11 Apr 2009 02:56:50 -0700 (PDT)
Message-ID: <20090411.025650.40194406.davem@davemloft.net>
References: <bug-13006-10286@http.bugzilla.kernel.org/>
	<1239417674-8374-1-git-send-email-brian.haley@hp.com>
	<623.1239432679@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, steve@astutenetworks.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	akpm@linux-foundation.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52608
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757294AbZDKJ47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 05:56:59 -0400
In-Reply-To: <623.1239432679@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 10 Apr 2009 23:51:19 -0700

> Brian Haley <brian.haley@hp.com> wrote:
> 
>>Fix a zero address hole bug in the bonding arp_ip_target list
>>that was causing the bond to ignore ARP replies (bugz 13006).
>>Instead of just setting the array entry to zero, we now
>>copy any additional entries down one slot, putting the
>>zero entry at the end.  With this change we can now have
>>all the loops that walk the array stop when they hit a zero
>>since there will be no addresses after it.
>>
>>Signed-off-by: Brian Haley <brian.haley@hp.com>
> 
> 	This all looks reasonable to me.  This patch appears to be an
> extension of some code (not as a patch) provided in bugzilla 13006 by
> Steve Howard <steve@astutenetworks.com>, so I suspect he should sign off
> on this as well, or at the very least be credited in the log; I'd write
> that as:
> 
> 	Changes are based in part on code fragment provided in kernel
> bugzilla 13006 by Steve Howard <steve@astutenetworks.com>.
> 
> 	This can go to -stable, too.
> 
> 	-J
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Indeed, please fix up the attribution and I will apply this and
queue up for -stable.
