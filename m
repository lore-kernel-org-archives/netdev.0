From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [Bugme-new] [Bug 13692] New: dccp_ipv4 has >1 usage count and
	cannot be removed
Date: Sat, 4 Jul 2009 20:45:36 +0200
Message-ID: <20090704184536.GA6233@gerrit.erg.abdn.ac.uk>
References: <474687.88131.qm@web37607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, dccp@vger.kernel.org
To: Alex Dubov <oakad@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60483 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750942AbZGDSqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jul 2009 14:46:11 -0400
Content-Disposition: inline
In-Reply-To: <474687.88131.qm@web37607.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 
| Well, I tried "rmmod -f" first thing after noticing this behavior
| and got a kernel crash dump immediately.
| 
| I'm not near that machine currently, but I'll post the crash dump on
| Monday.
| 
What is most important to know: did you do the "rmmod -f" while any
sockets were active? Did you have DCCP traffic going on before (not
assuming while) this happened?
(It is possible to see the current socket state using "ss -dane".)
