From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run;
	capabilities error
Date: Tue, 20 May 2008 08:49:19 -0500
Message-ID: <20080520134919.GA8079@sergelap.wowway.com>
References: <bug-10748-10286@http.bugzilla.kernel.org/> <20080519112835.67ff4133.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	shahamit@gmail.com, "Serge E. Hallyn" <serue@us.ibm.com>,
	Andrew Morgan <morgan@kernel.org>,
	Stephen Smalley <sds@tycho.nsa.gov>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:51174 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756864AbYETN0Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 09:26:16 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4KDQFPJ003582
	for <netdev@vger.kernel.org>; Tue, 20 May 2008 09:26:16 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4KDQFME140168
	for <netdev@vger.kernel.org>; Tue, 20 May 2008 09:26:15 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4KDQErq014033
	for <netdev@vger.kernel.org>; Tue, 20 May 2008 09:26:15 -0400
Content-Disposition: inline
In-Reply-To: <20080519112835.67ff4133.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Andrew Morton (akpm@linux-foundation.org):
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Mon, 19 May 2008 06:25:00 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10748
> > 
> >            Summary: dhclient fails to run; capabilities error
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.26-rc2
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: shahamit@gmail.com
> > 
> > 
> > Latest working kernel version: 2.6.25
> > Earliest failing kernel version: 2.6.26-rc1
> > Distribution: Kubuntu Hardy
> > Hardware Environment: AMD
> > Software Environment:
> > Problem Description: On a default Kubuntu Hardy install, I fetched the git tree
> > from Linus; compiled and installed the kernel. This persists even with
> > 2.6.26-rc2+ (commit f26a3988917913b3d11b2bd741601a2c64ab9204)
> > 
> > If this isn't known, I'll bisect and report the bad commit
> > 
> > Steps to reproduce: 'sudo dhclient eth2' returns
> > 
> > drop_privileges: could not keep capabilities: Invalid argument
> > 
> > eth2 is an e1000e card.
> > 
> > 
> 
> whoa, weird.  Could you please run `sudo strace -f dhclient eth2' and send us
> the last page or so of output?

Also, please send your .config, or at least the result of
grep SECURITY .config

thanks,
-serge
