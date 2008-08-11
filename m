From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Sun, 10 Aug 2008 20:30:31 -0400
Message-ID: <489F8827.4030904@hp.com>
References: <bug-11297-10286@http.bugzilla.kernel.org/> <20080809213101.0927a808.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: parag.warudkar@gmail.com, bugme-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:24668 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752734AbYHKAbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 20:31:05 -0400
In-Reply-To: <20080809213101.0927a808.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Can you please confirm the version numbers here?  2.6.26-rc4 was OK,
> but 2.6.26 and 2.6.27-rc2 are busted?

This commit would have broken this, which git-whatchanged shows as being 
in 2.6.24-rc4:

commit 5e5f3f0f801321078c897a5de0b4b4304f234da0
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 3 21:44:34 2008 +0900

     [IPV6] ADDRCONF: Convert ipv6_get_saddr() to ipv6_dev_get_saddr().

     Since most users of ipv6_get_saddr() pass non-NULL as
     dst argument, use ipv6_dev_get_saddr() directly.

     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Most people have default IPv6 routes, which is probably why it hasn't 
been seen.

> Brian had a patch but apparently things still aren't right (see the
> full bugzilla report for details).

John sent me email off-line saying the patch fixed the problem, but he'd 
do more testing over the weekend.

-Brian
