From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 12/15] driver core: Implement tagged directory support for device classes.
Date: Wed, 16 Jul 2008 12:07:25 -0700
Message-ID: <m1y7413axe.fsf@frodo.ebiederm.org>
References: <m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<m1r6aah2hh.fsf_-_@frodo.ebiederm.org>
	<m1mykyh2fu.fsf_-_@frodo.ebiederm.org>
	<m1hcb6h2d2.fsf_-_@frodo.ebiederm.org> <486DD650.3000804@gmail.com>
	<m1tzf593ny.fsf@frodo.ebiederm.org> <486E2C3B.6020603@gmail.com>
	<20080704161200.GA1440@suse.de> <m1lk052ptp.fsf@frodo.ebiederm.org>
	<487D6A24.9070001@gmail.com> <m17ibmbd39.fsf@frodo.ebiederm.org>
	<487D8C0A.9060100@gmail.com> <m11w1u9w5j.fsf@frodo.ebiederm.org>
	<487D99C7.708@gmail.com> <487D9D0C.3060105@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Tejun Heo <teheo@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55706 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755078AbYGPTMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 15:12:23 -0400
In-Reply-To: <487D9D0C.3060105@suse.de> (Tejun Heo's message of "Wed, 16 Jul
	2008 16:02:36 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <teheo@suse.de> writes:

> Okay, one small problem spotted.  It seems invalidate_inodes() can fail
> which will make generic_shutdown_super() complain.  It's not a fatal
> failure tho.

How when the inode list is empty?  We don't unmount the superblock that
has the inodes.

Eric
