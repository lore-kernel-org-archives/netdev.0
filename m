From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 29712] New: Bonding Driver(version : 3.5.0)
 - Problem with ARP monitoring in active backup mode
Date: Thu, 24 Feb 2011 22:42:29 -0500
Message-ID: <4D672525.5080609@hp.com>
References: <bug-29712-10286@https.bugzilla.kernel.org/> <20110224145129.f366b59e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: harsha.r02@mphasis.com, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:22315 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755927Ab1BYDmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 22:42:33 -0500
In-Reply-To: <20110224145129.f366b59e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2011 05:51 PM, Andrew Morton wrote:
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Wed, 23 Feb 2011 10:41:34 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
>> https://bugzilla.kernel.org/show_bug.cgi?id=29712
>>
>>            Summary: Bonding Driver(version : 3.5.0) - Problem with ARP
>>                     monitoring in active backup mode
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.32
> 
> That's a paleolithic kernel you have there.  This problem might have
> been fixed already.  Can you test a more recent kernel?

I can add some more info since I originally looked at the problem.  This
happens on 2.6.38 as well, and on this 2.6.32 kernel with a backported
3.7.0 bonding driver (with the primary_reselect option).  Harsha has a
prototype patch that's being tested, but wanted to log the bug to see
if one of the bonding maintainers had a better solution.

I'll let him respond as I'm now out of the loop...

Thanks,

-Brian
