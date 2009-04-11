From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] Bonding: fix zero address hole bug in arp_ip_target
 list
Date: Sat, 11 Apr 2009 11:52:25 -0700
Message-ID: <20090411115225.8559c713.akpm@linux-foundation.org>
References: <1239463202-7662-1-git-send-email-brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, steve@astutenetworks.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47366 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755305AbZDKSzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Apr 2009 14:55:25 -0400
In-Reply-To: <1239463202-7662-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 11 Apr 2009 11:20:02 -0400 Brian Haley <brian.haley@hp.com> wrote:

> Fix a zero address hole bug in the bonding arp_ip_target list
> that was causing the bond to ignore ARP replies (bugz 13006).
> Instead of just setting the array entry to zero, we now
> copy any additional entries down one slot, putting the
> zero entry at the end.  With this change we can now have
> all the loops that walk the array stop when they hit a zero
> since there will be no addresses after it.
> 
> Changes are based in part on code fragment provided in kernel
> bugzilla 13006 by Steve Howard <steve@astutenetworks.com>
> 

This isn't written down anywhere, but...

If the patch addresses a bugzilla report, please quote the full
bugzilla URL in the changelog.  ie:
http://bugzilla.kernel.org/show_bug.cgi?id=13006

Because people sometime will go through the commit logs closing off
bugzilla reports.  Using a standardised pattern for them to search for
helps in this activity.


