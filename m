From: Ming-Ching Tiew <mingching.tiew@redtone.com>
Subject: Re: [Bugme-new]  [Bug 9719] New: when a system is configured as a
 bridge, and at the same time configured to have multipath weighted route,
 with one leg goes thru NAT and another without NAT, the nat path will intermittently
 get packets leaking out using internal IP without being SNAT-ted
Date: Thu, 10 Jan 2008 21:07:10 +0800
Message-ID: <4786187E.3090000@redtone.com>
References: <bug-9719-10286@http.bugzilla.kernel.org/> <20080109152813.83fb8168.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.cnx.com.my ([202.46.113.21]:4971 "EHLO mail.cnx.com.my"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756825AbYAJAU3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 19:20:29 -0500
In-Reply-To: <20080109152813.83fb8168.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
>
> On Wed,  9 Jan 2008 11:55:50 -0800 (PST)
> bugme-daemon@bugzilla.kernel.org wrote:
>
>   
>> http://bugzilla.kernel.org/show_bug.cgi?id=9719
>>
>>            Summary: when a system is configured as a bridge, and at the same
>>                     time configured to have multipath weighted route, with
>>                     one leg goes thru NAT and another without NAT, the nat
>>                     path will intermittently get packets leaking out using
>>                     internal IP without being SNAT-ted
>>            Product: Networking
>>            Version: 2.5
>>      KernelVersion: 2.6.22.15 and 2.6.23
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Netfilter/Iptables
>>         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
>>         ReportedBy: mingching.tiew@redtone.com
>>
>>
>> Latest working kernel version: 2.6.23
>> Earliest failing kernel version: 2.6.22.15
>>     
>
> This doesn't make sense.  What we're trying to ask here (and we've been
> unable to find a pair of questions which 100% of reporters can successfully
> answer) is whether this is a regression, and in which kernel release did we
> regress?
>
> In other words: did we break it, and if so, when did we break it?
>   

Sorry for the confusion and for such a lousy first time bug reporter.

I realized that mistake immediately after I posted it on the web 
interface. However, the web interface does not seem to allow me to 
correct that.

What I meant was that it failed on both the kernel versions I tested. I 
am afraid it  is a problem which exists all a long. Perhaps it has been 
broken quite sometime already. I need to go back to try some older 
kernel version and see if I could repeat the problem.

Regards.

