From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [GIT]: Networking
Date: Tue, 08 Dec 2009 17:54:47 -0800
Message-ID: <m1ein4zzbs.fsf@fess.ebiederm.org>
References: <20091205.193505.193701079.davem@davemloft.net>
	<20091208194530.GA24530@elte.hu>
	<20091208.125032.70743046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:36965 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387AbZLIByt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 20:54:49 -0500
In-Reply-To: <20091208.125032.70743046.davem@davemloft.net> (David Miller's message of "Tue\, 08 Dec 2009 12\:50\:32 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 8 Dec 2009 20:45:30 +0100
>
>> i just switched to today's -git tree and there's this new build failure 
>> on x86:
>> 
>>  net/sctp/sysctl.c:251: error: unknown field 'strategy' specified in initializer
>>  net/sctp/sysctl.c:251: error: 'sysctl_intvec' undeclared here (not in a function)
>> 
>> havent looked into it yet - config attached.
>
> It's probably a conflict with Eric Beiderman's sysctl cleanups that
> got merged in at the same time.

Yep. You guys figured it out.  Thanks all.

I have looked and I don't see any more .ctl_name or .strategy fields
left in the kernel so this should be the last of it.

Hooray!  Maintenance of binary sysctl is gone!

Eric
