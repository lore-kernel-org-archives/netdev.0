From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8876] New: Not all IPs are shown by
 "ip addr show"
Date: Fri, 10 Aug 2007 09:43:51 -0700
Message-ID: <20070810094351.cb548415.akpm@linux-foundation.org>
References: <bug-8876-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gentuu@gmail.com,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39757 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759908AbXHJQoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 12:44:38 -0400
In-Reply-To: <bug-8876-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 10 Aug 2007 05:58:25 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8876
> 
>            Summary: Not all IPs are shown by "ip addr show"
>            Product: Networking
>            Version: 2.5
>      KernelVersion: >=2.6.22 (2.6.23.x too)
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@osdl.org
>         ReportedBy: gentuu@gmail.com
> 
> 
> Most recent kernel where this bug did not occur: 2.6.21.x

a regression.

> Distribution: no matter
> Hardware Environment: generic i686
> Software Environment: GNU
> Problem Description:
> Not all ips are shown by "ip addr show" command when IPs number assigned to an
> interface is more than 60-80 (in fact it depends on broadcast/label etc
> presence on each address).
> 
> Steps to reproduce:
> It's terribly simple to reproduce:
> 
> # for i in $(seq 1 100); do ip ad add 10.0.$i.1/24 dev eth10 ; done
> # ip addr show
> 
> this will _not_ show all IPs.
> Looks like the problem is in netlink/ipv4 message processing.
> 
