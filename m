From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 09/15] sysfs: Implement sysfs tagged directory support.
Date: Tue, 19 Aug 2008 23:58:14 -0700
Message-ID: <m1tzdgw4u1.fsf@frodo.ebiederm.org>
References: <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<20080820021754.GA25182@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58250 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbYHTHEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 03:04:05 -0400
In-Reply-To: <20080820021754.GA25182@kroah.com> (Greg KH's message of "Tue, 19
	Aug 2008 19:17:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH <greg@kroah.com> writes:

> On Thu, Jul 03, 2008 at 06:16:08PM -0700, Eric W. Biederman wrote:
>> 
>> The problem.  When implementing a network namespace I need to be able
>> to have multiple network devices with the same name.  Currently this
>> is a problem for /sys/class/net/*, /sys/devices/virtual/net/*, and
>> potentially a few other directories of the form /sys/ ... /net/*.
>
> <snip>
>
> I applied the patches up to here (well, patch 8 was no longer needed at
> all anymore), but this one doesn't apply at all.
>
> Care to respin these last few patches?

Sounds like a plan.

Looks like we are just talking about the driver core patches so while a pain
it actually should not be too hard.

I will get a copy of your gregkh tree from kernel.org tomorrow and see
what I can do.

Eric
