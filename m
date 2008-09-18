From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Thu, 18 Sep 2008 11:09:31 -0700
Message-ID: <m18wtpuy04.fsf@frodo.ebiederm.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	<20080917125053.1f9ecf37.akpm@linux-foundation.org>
	<200809171724.36269.paul.moore@hp.com>
	<20080917144842.7df59f9e.akpm@linux-foundation.org>
	<m17i9axv1q.fsf@frodo.ebiederm.org>
	<1221741521.24048.17.camel@moss-spartans.epoch.ncsc.mil>
	<1221742980.24048.26.camel@moss-spartans.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Paul Moore <paul.moore@hp.com>, jmorris@namei.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54657 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753252AbYIRSPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 14:15:23 -0400
In-Reply-To: <1221742980.24048.26.camel@moss-spartans.epoch.ncsc.mil> (Stephen
	Smalley's message of "Thu, 18 Sep 2008 09:03:00 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Smalley <sds@tycho.nsa.gov> writes:

> On Thu, 2008-09-18 at 08:38 -0400, Stephen Smalley wrote:
>> I do however think that the mantra that we can't require users to update
>> policy for kernel changes is unsupportable in general.  The precise set
>> of permission checks on a given operation is not set in stone and it is
>> not part of the kernel/userland interface/contract.  Policy isn't
>> "userspace"; it governs what userspace can do, and it has to adapt to
>> kernel changes.
>
> I should note here that for changes to SELinux, we have gone out of our
> way to avoid such breakage to date through the introduction of
> compatibility switches, policy flags to enable any new checks, etc
> (albeit at a cost in complexity and ever creeping compatibility code).
> But changes to the rest of the kernel can just as easily alter the set
> of permission checks that get applied on a given operation, and I don't
> think we are always going to be able to guarantee that new kernel + old
> policy will Just Work. 

I know of at least 2 more directories that I intend to turn into
symlinks into somewhere under /proc/self.  How do we keep from
breaking selinux policies when I do that?

For comparison how do we handle sysfs? 
How do we handle device nodes in tmpfs?
Ultimately do we want to implement xattrs and inotify on /proc?  
Or is there another way that would simplify maintenance?

Eric
