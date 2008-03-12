From: Andrew Morton <akpm@linux-foundation.org>
Subject: netconsole still hangs
Date: Wed, 12 Mar 2008 16:14:29 -0700
Message-ID: <20080312161429.d5b1c67b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48900 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751543AbYCLXPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2008 19:15:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I thought the recent reverts fixed this, but it seems that it's just become
a little harder to hit.

I'm seeing netconsole hangs on two x86_64 systems (2-way t61p laptop, 8-way
server).  Both use e1000.

With current mainline on the 8-way, create a printk storm with

while true
do
	echo t > /proc/sysrq-trigger
done

and the machine goes tits-up after about five seconds.

