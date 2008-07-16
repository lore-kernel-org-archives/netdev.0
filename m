From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Tue, 15 Jul 2008 22:41:14 -0700
Message-ID: <m17ibmbd39.fsf@frodo.ebiederm.org>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>
	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>
	<487D6A24.9070001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52344 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbYGPFma (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 01:42:30 -0400
In-Reply-To: <487D6A24.9070001@gmail.com> (Tejun Heo's message of "Wed, 16 Jul
	2008 12:25:24 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <htejun@gmail.com> writes:

> Greg, please disregard my earlier NACKs and commit the patches if you're
> okay with them.  I'm working on cleaning it up but I don't think I'll be
> able to make it in time for merge window and as Eric said getting the
> functionality in place is more important at this point as it doesn't
> affect user visible interface.
>
> Eric, with the multiple superblocks, sysfs now uses inode from the
> default sysfs_sb with dentries from other sb's.  Is this okay?  Are
> there any other filesystems which do this?

I don't know of any other filesystems where this unique challenge arises.
/proc almost qualifies but it never needs to be modified.

It is certainly ok to go from multiple dentries to a single inode.
I'm trying to remember why I choose to do that.  I think both because it simplifies
the locking and keeps us more efficient in the icache.

Eric
