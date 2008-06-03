From: James Cammarata <jimi@sngx.net>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Tue, 03 Jun 2008 07:28:57 -0500
Message-ID: <48453909.4000301@sngx.net>
References: <482DA5B6.1020606@sngx.net>	<482DB46A.8020103@cosmosbay.com>	<482EF192.4070707@sngx.net>	<482F5113.5090703@cosmosbay.com>	<482F610D.2080108@sngx.net>	<20080518003104.GK28241@solarflare.com>	<482FBA09.80201@sngx.net>	<483E0AAE.2020107@sngx.net>	<20080528221118.63da4092.akpm@linux-foundation.org>	<483EA2D1.8050603@sngx.net>	<20080529154525.3916c7b5@core>	<20080530151250.b44a119a.billfink@mindspring.com>	<20080531131143.516ca56e@core>	<20080531195702.0b879dd1.billfink@mindspring.com>	<48437C25.7080400@gdt.id.au> <20080602121007.1e81cf05.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl093-193-175.stl1.dsl.speakeasy.net ([66.93.193.175]:59575
	"EHLO hades.sngx.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752342AbYFCM1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:27:03 -0400
In-Reply-To: <20080602121007.1e81cf05.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> First of all, when assisting a user, they typically aren't even
> running an snmp daemon (and there might be firewall issues to
> access it if they are).  And I don't think the "ethtool -S" driver
> stats are even accessible via SNMP (although they may contribute
> to more generic interface stats which are), and it is the specific
> driver stats which are often key to help diagnosing the problem.

Ok, just to jump back in and add my $0.02, I plan to send a patch to 
the ethtool project to do what was suggested (snapshot to /var, and 
diff stats against that for future reference).  I would just like to 
point out that this will introduce inconsistencies between _every_ 
other source of interface stats (ifconfig/procfs/etc).  I can deal 
with that, it just means one more thing to keep track of when you're 
troubleshooting.

Also, I'd like to point out that the "stepping on other peoples toes" 
argument is a bogus one, since most major network vendors include this 
ability, and it's not exactly a concern now.
