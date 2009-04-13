From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Bonding: fix zero address hole bug in arp_ip_target
 list
Date: Mon, 13 Apr 2009 00:12:01 -0700 (PDT)
Message-ID: <20090413.001201.127700351.davem@davemloft.net>
References: <1239463202-7662-1-git-send-email-brian.haley@hp.com>
	<20090411115225.8559c713.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, fubar@us.ibm.com, steve@astutenetworks.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750815AbZDMHMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 03:12:10 -0400
In-Reply-To: <20090411115225.8559c713.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Sat, 11 Apr 2009 11:52:25 -0700

> On Sat, 11 Apr 2009 11:20:02 -0400 Brian Haley <brian.haley@hp.com> wrote:
> 
>> Fix a zero address hole bug in the bonding arp_ip_target list
>> that was causing the bond to ignore ARP replies (bugz 13006).
>> Instead of just setting the array entry to zero, we now
>> copy any additional entries down one slot, putting the
>> zero entry at the end.  With this change we can now have
>> all the loops that walk the array stop when they hit a zero
>> since there will be no addresses after it.
>> 
>> Changes are based in part on code fragment provided in kernel
>> bugzilla 13006 by Steve Howard <steve@astutenetworks.com>
>> 
> 
> This isn't written down anywhere, but...
> 
> If the patch addresses a bugzilla report, please quote the full
> bugzilla URL in the changelog.  ie:
> http://bugzilla.kernel.org/show_bug.cgi?id=13006

I've fixed this when checking in Brian's patch, and also
queued it up for -stable.

Thanks!
