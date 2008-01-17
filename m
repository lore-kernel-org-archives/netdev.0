From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9767] New: missing native u32 classifier for
 routing policy
Date: Thu, 17 Jan 2008 00:46:12 -0800
Message-ID: <20080117004612.e815a3e0.akpm@linux-foundation.org>
References: <bug-9767-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, pupilla@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39458 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753972AbYAQIqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 03:46:02 -0500
In-Reply-To: <bug-9767-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2008 00:30:49 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9767
> 
>            Summary: missing native u32 classifier for routing policy
>            Product: Networking
>            Version: 2.5
>      KernelVersion: all since 2.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: pupilla@hotmail.com
> 
> 
> This is not a bug report, but a feature request.
> routing policy database management is supported since linux 2.2, but it lacks
> u32 selector (matching by IP protocols, transport ports).
> fwmark is a workaround for this missing feature, but source ip address
> selection will not work anyway: the mark value can't be used for source address
> selection because at the time source address selection is performed, there is
> no packet yet and thus no mark value.
> 
