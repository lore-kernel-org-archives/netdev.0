From: Herbert Poetzl <herbert@13thfloor.at>
Subject: Re: [PATCH 50/59] sysctl: Move utsname sysctls to their own file
Date: Mon, 22 Jan 2007 23:24:42 +0100
Message-ID: <20070122222442.GD11128@MAIL.13thfloor.at>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com> <11689656853154-git-send-email-ebiederm@xmission.com> <45AE5FDC.5050603@sw.ru> <m1ps9d8n79.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@sw.ru>, James.Bottomley@SteelEye.com,
	linux-parport@lists.infradead.org, rtc-linux@googlegroups.com,
	linux-mips@linux-mips.org, heiko.carstens@de.ibm.com,
	containers@lists.osdl.org, lethal@linux-sh.org, clemens@ladisch.de,
	xfs@oss.sgi.com, xfs-masters@oss.sgi.com, paulus@samba.org,
	linux390@de.ibm.com, openipmi-developer@lists.sourceforge.net,
	linux-390@vm.marist.edu, aharkes@cs.cmu.edu, tim@cyberelk.net,
	codalist@TELEMANN.coda.cs.cmu.edu, a.zummo@towertech.it,
	tony.luck@intel.com, minyard@acm.org, linux-scsi@vger.kernel.org,
	linuxppc-dev@ozlabs.org, linux-ntfs-dev@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ralf@linux-mips.org, mark.fasheh@oracle.com, coda@cs.cmu.edu,
	vojtech@suse.cz, kurt.hackel@oracle.com, schwidefsky@de.ibm.com,
	aia21@cantab.net, philb@gnu.org, andrea@suse.de,
	linuxsh-shmedia-dev@lists.sourceforg
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL.13thfloor.at ([213.145.232.33]:55069 "EHLO
	MAIL.13thfloor.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932436AbXAVWYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 17:24:45 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
Content-Disposition: inline
In-Reply-To: <m1ps9d8n79.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 12:31:22PM -0700, Eric W. Biederman wrote:
> Kirill Korotaev <dev@sw.ru> writes:
> 
> > Eric, though I personally don't care much:
> > 1. I ask for not setting your authorship/copyright on the code which you just
> > copied
> >   from other places. Just doesn't look polite IMHO.
> 
> I can't claim complete ownership of the code, there was plenty of feed back
> and contributions from others but the final form without a big switch
> statement is mine.  I certainly can't claim the table, it has been in
> that form for years.
> 
> If you notice I actually didn't say whose copyright it was :)  just
> that I wrote the file.
> 
> If there are copyright claims I should include I will be happy to do that.
> Mostly I was just trying to find some stupid boiler plate that would work.

IMHO that is fine ...

> > 2. I would propose to not introduce utsname_sysctl.c.
> >   both files are too small and minor that I can't see much reasons splitting
> > them.
> 
> The impact of moving this code out of sysctl.c is a major
> simplification, to sysctl.c.  Putting them in their own file means we
> can cleanly restrict the code to only be compiled CONFIG_SYSCTL is set.
> 
> It is a necessary first step to implementing a per process /proc/sys.
> 
> It reorganizes the ipc and utsname sysctl from a terribly fragile
> structure to something that is robust and easy to follow.  Code
> scattered all throughout sysctl.c was just a disaster.  We had
> several instances of having to fix bugs with odd combinations of
> CONFIG options, simply because the other spot that needed to be touched
> wasn't obvious.
> 
> So from my perspective this is an extremely worthwhile change that
> will make maintenance easier and is a small first step towards
> some nice future functionality.

yep, agreed ...

best,
Herbert

> Eric
> _______________________________________________
> Containers mailing list
> Containers@lists.osdl.org
> https://lists.osdl.org/mailman/listinfo/containers
