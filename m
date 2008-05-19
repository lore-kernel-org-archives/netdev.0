From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10748] New: dhclient fails to run;
 capabilities error
Date: Mon, 19 May 2008 11:28:35 -0700
Message-ID: <20080519112835.67ff4133.akpm@linux-foundation.org>
References: <bug-10748-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, shahamit@gmail.com,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Andrew Morgan <morgan@kernel.org>,
	Stephen Smalley <sds@tycho.nsa.gov>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36450 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751817AbYESSeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 14:34:14 -0400
In-Reply-To: <bug-10748-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 19 May 2008 06:25:00 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10748
> 
>            Summary: dhclient fails to run; capabilities error
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.26-rc2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: shahamit@gmail.com
> 
> 
> Latest working kernel version: 2.6.25
> Earliest failing kernel version: 2.6.26-rc1
> Distribution: Kubuntu Hardy
> Hardware Environment: AMD
> Software Environment:
> Problem Description: On a default Kubuntu Hardy install, I fetched the git tree
> from Linus; compiled and installed the kernel. This persists even with
> 2.6.26-rc2+ (commit f26a3988917913b3d11b2bd741601a2c64ab9204)
> 
> If this isn't known, I'll bisect and report the bad commit
> 
> Steps to reproduce: 'sudo dhclient eth2' returns
> 
> drop_privileges: could not keep capabilities: Invalid argument
> 
> eth2 is an e1000e card.
> 
> 

whoa, weird.  Could you please run `sudo strace -f dhclient eth2' and send us
the last page or so of output?
