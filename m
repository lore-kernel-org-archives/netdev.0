From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 14330] New: Kernel
Date: Tue, 13 Oct 2009 20:43:26 -0700 (PDT)
Message-ID: <20091013.204326.219351074.davem@davemloft.net>
References: <bug-14330-10286@http.bugzilla.kernel.org/>
	<20091013194806.e1403ca9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hannes@stressinduktion.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753705AbZJNDna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 23:43:30 -0400
In-Reply-To: <20091013194806.e1403ca9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 13 Oct 2009 19:48:06 -0700

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Fixed by:

commit a21090cff296eb82b6de09304d64de466bdcaefc
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Wed Oct 7 03:18:17 2009 -0700

    ipv4: arp_notify address list bug
    
    This fixes a bug with arp_notify.
    
    If arp_notify is enabled, kernel will crash if address is changed
    and no IP address is assigned.
      http://bugzilla.kernel.org/show_bug.cgi?id=14330
    
    Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

