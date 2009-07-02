From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13692] New: dccp_ipv4 has >1 usage count and
 cannot be removed
Date: Thu, 2 Jul 2009 15:18:07 -0700
Message-ID: <20090702151807.aa5b8447.akpm@linux-foundation.org>
References: <bug-13692-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, oakad@yahoo.com,
	dccp@vger.kernel.org
To: netdev@vger.kernel.org,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34419 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752949AbZGBWSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:18:18 -0400
In-Reply-To: <bug-13692-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 2 Jul 2009 09:31:39 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13692
> 
>            Summary: dccp_ipv4 has >1 usage count and cannot be removed
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.30
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: oakad@yahoo.com
>         Regression: No
> 
> 
> Upon loading of dccp_ipv4 (either through autoload or explicitly, with
> modprobe) the usage count of the module is immediately set to 2 and the module
> can not be unloaded.
> 
> Usage count seems to be correctly incremented/decremented during operation, but
> never gets lower than 2.
> 

