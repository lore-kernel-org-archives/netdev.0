From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] tagged sysfs support
Date: Tue, 30 Mar 2010 11:30:23 -0700
Message-ID: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The main short coming of using multiple network namespaces today
is that only network devices for the primary network namespaces
can be put in the kobject layer and sysfs.

This is essentially the earlier version of this patchset that was
reviewed before, just now on top of a version of sysfs that doesn't
need cleanup patches to support it.

I have been running these patches in some form for well over a
year so the basics should at least be solid.  

This patchset is currently against 2.6.34-rc1.

This patchset is just the basic infrastructure a couple of more pretty
trivial patches are needed to actually enable network namespaces to use this.
My current plan is to send those after these patches have made it through
review.

 drivers/base/class.c    |    9 ++++
 drivers/base/core.c     |   98 +++++++++++++++++++++++++++++++++----------
 drivers/gpio/gpiolib.c  |    2 +-
 drivers/md/bitmap.c     |    4 +-
 drivers/md/md.c         |    6 +-
 fs/sysfs/bin.c          |    2 +-
 fs/sysfs/dir.c          |  106 ++++++++++++++++++++++++++++++++++++-----------
 fs/sysfs/file.c         |   17 ++++---
 fs/sysfs/group.c        |    6 +-
 fs/sysfs/inode.c        |    6 ++-
 fs/sysfs/mount.c        |   91 +++++++++++++++++++++++++++++++++++++++-
 fs/sysfs/symlink.c      |   35 ++++++++++++++-
 fs/sysfs/sysfs.h        |   23 ++++++++--
 include/linux/device.h  |    3 +
 include/linux/kobject.h |   26 +++++++++++
 include/linux/sysfs.h   |   18 ++++++++
 lib/kobject.c           |  104 ++++++++++++++++++++++++++++++++++++++++++++++
 17 files changed, 480 insertions(+), 76 deletions(-)

Eric
