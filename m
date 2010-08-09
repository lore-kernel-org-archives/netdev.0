From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net: allow netdev_wait_allrefs() to run faster
Date: Mon, 09 Aug 2010 10:23:37 -0700
Message-ID: <4C603999.1030801@candelatech.com>
References: <20091017221857.GG1925@kvack.org> <4ADB55BC.5020107@gmail.com> <20091018182144.GC23395@kvack.org> <200910211539.01824.opurdila@ixiacom.com> <4ADF2B57.4030708@gmail.com> <20091021165139.GL877@kvack.org> <m1d445yf2x.fsf@fess.ebiederm.org> <20091029233848.GV3141@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev@vger.kernel.org, Cosmin Ratiu <cratiu@ixiacom.com>
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60827 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750834Ab0HIRXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 13:23:46 -0400
In-Reply-To: <20091029233848.GV3141@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2009 04:38 PM, Benjamin LaHaise wrote:
> On Thu, Oct 29, 2009 at 04:07:18PM -0700, Eric W. Biederman wrote:
>> Could you keep me in the loop with that.  I have some pending cleanups for
>> all of those pieces of code and may be able to help/advice/review.
>
> Here are the sysfs scaling improvements.  I have to break them up, as there
> are 3 separate changes in this patch: 1. use an rbtree for name lookup in
> sysfs, 2. keep track of the number of directories for the purpose of
> generating the link count, as otherwise too much cpu time is spent in
> sysfs_count_nlink when new entries are added, and 3. when adding a new
> sysfs_dirent, walk the list backwards when linking it in, as higher
> numbered inodes tend to be at the end of the list, not the beginning.

I was just comparing my out-of-tree patch set to .35, and it appears
little or none of the patches discussed in this thread are in the
upstream kernel yet.

Specifically, there is still that msleep(250) in
netdev_wait_allrefs

Is anyone still trying to get the improvements needed for adding/deleting
lots of interfaces into the kernel?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

