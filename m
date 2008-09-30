From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 00/30] Swap over NFS -v18
Date: Tue, 30 Sep 2008 17:46:26 +0200
Message-ID: <48E249D2.2060805@fr.ibm.com>
References: <20080724140042.408642539@chello.nl> <1222778476.9044.1.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Neil Brown <neilb@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:43101 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753215AbYI3Pqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 11:46:35 -0400
In-Reply-To: <1222778476.9044.1.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Zijlstra wrote:
> On Thu, 2008-07-24 at 16:00 +0200, Peter Zijlstra wrote:
>> Latest version of the swap over nfs work.
>>
>> Patches are against: v2.6.26-rc8-mm1
>>
>> I still need to write some more comments in the reservation code.
>>
>> Pekka, it uses ksize(), please have a look.
>>
>> This version also deals with network namespaces.
>> Two things where I could do with some suggestsion:
>>
>>   - currently the sysctl code uses current->nrproxy.net_ns to obtain
>>     the current network namespace
>>
>>   - the ipv6 route cache code has some initialization order issues
> 
> Daniel, have you ever found time to look at my namespace issues?

Oops, no. I was busy and I forgot, sorry.
Let me review the sysctl vs namespace part.

Thanks
   -- Daniel
