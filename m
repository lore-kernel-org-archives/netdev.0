From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/8] sysfs namespace support
Date: Wed, 20 Aug 2008 23:31:00 -0700
Message-ID: <m1od3m282j.fsf_-_@frodo.ebiederm.org>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:46296 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbYHUGeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:34:04 -0400
In-Reply-To: <20080820021754.GA25182@kroah.com> (Greg KH's message of "Tue, 19
	Aug 2008 19:17:54 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Greg the first 4 patches are the rest of the infrastructure.
Everything rebased quite nicely.  All of the conflicts appear
to have been false positives.

With the addition of sysfs_rename_link sysfs_create_link_nowarn
is never called so we can remove it.

I'm not really certain whose tree the last netns or the user
namespace changes should live in, but I am continuing to
have those patches in this patchset for completeness.

Eric W. Biederman (7):
1      sysfs: Implement sysfs tagged directory support.
2      sysfs: Merge sysfs_rename_dir and sysfs_move_dir
3      sysfs: Implement sysfs_delete_link and sysfs_rename_link
4      driver core: Implement tagged directory support for device classes.

5      sysfs: Remove sysfs_create_link_nowarn

6      Revert "netns: Fix device renaming for sysfs"
7      netns: Enable tagging for net_class directories in sysfs

Serge Hallyn (1):
8      sysfs: user namespaces: fix bug with clone(CLONE_NEWUSER) with fairsched
