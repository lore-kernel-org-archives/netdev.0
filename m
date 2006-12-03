From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Network virtualization/isolation
Date: Sun, 03 Dec 2006 09:00:59 -0700
Message-ID: <m1y7ppdl50.fsf@ebiederm.dsl.xmission.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com>
	<20061026085659.33b4c6dd@freekitty>
	<200610271134.56830.dim@openvz.org> <4541CCF4.4050306@fr.ibm.com>
	<1162391707.5251.78.camel@jzny2> <4559DE01.5090109@fr.ibm.com>
	<m1y7pzoptr.fsf@ebiederm.dsl.xmission.com>
	<456C447E.5090703@fr.ibm.com>
	<m1r6vnikeq.fsf@ebiederm.dsl.xmission.com>
	<456C9B8C.1010701@fr.ibm.com>
	<m14psji6lw.fsf@ebiederm.dsl.xmission.com> <456DEBAC.4060106@hp.com>
	<456E055F.8020100@fr.ibm.com> <1165148762.3517.58.camel@localhost>
	<1165155198.3517.86.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, devel@openvz.org,
	Linux Containers <containers@lists.osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:3205 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S1754282AbWLCQDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 11:03:03 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165155198.3517.86.camel@localhost> (hadi@cyberus.ca's message
	of "Sun, 03 Dec 2006 09:13:18 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok.  Just a quick summary of where I see the discussion.

We all agree that L2 isolation is needed at some point.

The approaches discussed for L2 and L3 are sufficiently orthogonal
that we can implement then in either order.  You would need to
unshare L3 to unshare L2, but if we think of them as two separate
namespaces we are likely to be in better shape.

The L3 discussion still has the problem that there has not been
agreement on all of the semantics yet.

More comments after I get some sleep.

Eric
