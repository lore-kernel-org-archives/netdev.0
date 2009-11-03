From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 1/3] sysfs directory scaling: rbtree for dirent name lookups
Date: Tue, 03 Nov 2009 14:18:53 -0800
Message-ID: <m1zl735k1e.fsf@fess.ebiederm.org>
References: <20091101163130.GA7911@kvack.org>
	<20091103035058.GA19515@kroah.com> <20091103200155.GQ8227@kvack.org>
	<m1my338fbi.fsf@fess.ebiederm.org> <20091103215251.GS8227@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>,
	linux-kernel@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59301 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930AbZKCWSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 17:18:52 -0500
In-Reply-To: <20091103215251.GS8227@kvack.org> (Benjamin LaHaise's message of "Tue\, 3 Nov 2009 16\:52\:51 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> On Tue, Nov 03, 2009 at 01:32:33PM -0800, Eric W. Biederman wrote:
>> Are your numbers from your application and are they real world?
>> In which case they are interesting, but it would be good if
>> we could also have microbenchmark numbers that just measure
>> the sysfs costs.   If nothing else I am seeing a big startup
>> overhead that isn't being subtracted out that makes it hard
>> to see the real costs here.
>
> They're application based, so there's a bunch of other overhead included 
> that won't show up on a microbenchmark.  Each interface requires a round 
> trip between 2 L2TP daemons, so there are lots of syscalls and other cache 
> polluting effects that won't show up on a microbenchmark.  One of the L2TP 
> daemons is configured not to instantiate any kernel state -- running in 
> this mode, it has very little overhead.
>
> The other thing to note is that the costs posted are how long it takes to 
> add an additional 5,000 interfaces in the given range, not the total time 
> to add say 35,000 interfaces (I didn't feel like waiting that long).

Ok.  That makes a lot more sense.  The times you posted ideally would be flat
but they go up from 12s to 60s.

Eric
