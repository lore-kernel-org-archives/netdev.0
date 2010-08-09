From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 09 Aug 2010 12:59:14 -0700
Message-ID: <m1tyn3v9pp.fsf@fess.ebiederm.org>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com>
	<20091018182144.GC23395@kvack.org>
	<200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com>
	<20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org>
	<20091029233848.GV3141@kvack.org> <4C603999.1030801@candelatech.com>
	<20100809173429.GR30010@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60435 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755535Ab0HIT7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:59:21 -0400
In-Reply-To: <20100809173429.GR30010@kvack.org> (Benjamin LaHaise's message of
	"Mon, 9 Aug 2010 13:34:29 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise <bcrl@lhnet.ca> writes:

> Hello Ben,
>
> On Mon, Aug 09, 2010 at 10:23:37AM -0700, Ben Greear wrote:
>> I was just comparing my out-of-tree patch set to .35, and it appears
>> little or none of the patches discussed in this thread are in the
>> upstream kernel yet.

The network device deletion batching code has gone in, which is
a big help, as have some dev_put deletions, so we hit that 250ms
delay less often.  

> I was waiting on Eric's sysfs changes for namespaces to settle down, but 
> ended up getting busy on other things.  I guess now is a good time to pick 
> this back up and try to merge my changes for improving interface scaling.  
> I'll send out a new version of the patches sometime in the next couple of 
> days.  I'm also about to make a new Babylon release as well, I just need 
> to write some more documentation. :-/

sysfs feature wise has now settled down, and the regressions have all
been stamped out so now should be a good time to work on scaling.

I still have some preliminary patches in my tree, that I will dig up
as time goes by.

Eric
