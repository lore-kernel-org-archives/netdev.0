From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: add ability to clear stats via ethtool - e1000/pcnet32
Date: Tue, 3 Jun 2008 13:35:22 +0100
Message-ID: <20080603123520.GF18161@solarflare.com>
References: <483E0AAE.2020107@sngx.net> <20080528221118.63da4092.akpm@linux-foundation.org> <483EA2D1.8050603@sngx.net> <20080529154525.3916c7b5@core> <20080530151250.b44a119a.billfink@mindspring.com> <20080531131143.516ca56e@core> <20080531195702.0b879dd1.billfink@mindspring.com> <48437C25.7080400@gdt.id.au> <20080602121007.1e81cf05.billfink@mindspring.com> <48453909.4000301@sngx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Fink <billfink@mindspring.com>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: James Cammarata <jimi@sngx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:43110 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753399AbYFCMfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:35:33 -0400
Content-Disposition: inline
In-Reply-To: <48453909.4000301@sngx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Cammarata wrote:
> >First of all, when assisting a user, they typically aren't even
> >running an snmp daemon (and there might be firewall issues to
> >access it if they are).  And I don't think the "ethtool -S" driver
> >stats are even accessible via SNMP (although they may contribute
> >to more generic interface stats which are), and it is the specific
> >driver stats which are often key to help diagnosing the problem.
> 
> Ok, just to jump back in and add my $0.02, I plan to send a patch to 
> the ethtool project to do what was suggested (snapshot to /var, and 
> diff stats against that for future reference).  I would just like to 
> point out that this will introduce inconsistencies between _every_ 
> other source of interface stats (ifconfig/procfs/etc).  I can deal 
> with that, it just means one more thing to keep track of when you're 
> troubleshooting.

You could perhaps add a third column to the statistics when a snapshot
exists, with the second column still showing absolute values and the
third showing the difference from the snapshot.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
