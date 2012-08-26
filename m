From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 0/15] userns subsystem conversions
Date: Sun, 26 Aug 2012 07:25:46 -0700
Message-ID: <87txvp91cl.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
	<9E0E8AAC-9548-4009-AE29-D368244D8EEA@dubeyko.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: Vyacheslav Dubeyko <slava@dubeyko.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49837 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754229Ab2HZOZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Aug 2012 10:25:59 -0400
In-Reply-To: <9E0E8AAC-9548-4009-AE29-D368244D8EEA@dubeyko.com> (Vyacheslav
	Dubeyko's message of "Sun, 26 Aug 2012 16:29:03 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vyacheslav Dubeyko <slava@dubeyko.com> writes:

> HI,
>
> On Aug 26, 2012, at 3:54 AM, Eric W. Biederman wrote:
>> 
>> fs/9p/acl.c                       |    8 +-
>> fs/btrfs/acl.c                    |    8 +-
>> fs/configfs/inode.c               |    4 +-
>> fs/debugfs/inode.c                |   26 +++--
>> fs/ext2/acl.c                     |   32 ++++--
>> fs/ext3/acl.c                     |   32 ++++--
>> fs/ext4/acl.c                     |   31 ++++--
>> fs/generic_acl.c                  |    4 +-
>> fs/gfs2/acl.c                     |   14 ++--
>> fs/gfs2/quota.c                   |   44 +++++---
>> fs/jffs2/acl.c                    |    4 +-
>> fs/jfs/acl.c                      |    4 +-
>> fs/jfs/xattr.c                    |    4 +-
>> fs/nfs/nfs3acl.c                  |    4 +-
>> fs/nfsd/vfs.c                     |    8 +-
>> fs/ocfs2/acl.c                    |    4 +-
>> fs/ocfs2/file.c                   |    6 +-
>> fs/ocfs2/quota_global.c           |   34 +++++--
>> fs/ocfs2/quota_local.c            |   12 ++-
>> fs/posix_acl.c                    |   30 +++---
>> fs/proc/base.c                    |   12 ++-
>> fs/quota/dquot.c                  |   43 ++++----
>> fs/quota/netlink.c                |   11 ++-
>> fs/quota/quota.c                  |   44 +++++---
>> fs/quota/quota_tree.c             |   20 +++-
>> fs/quota/quota_v1.c               |    8 +-
>> fs/quota/quota_v2.c               |   14 ++-
>> drivers/connector/cn_proc.c       |   18 +++-
>> drivers/gpu/drm/drm_fops.c        |    3 +-
>> drivers/gpu/drm/drm_info.c        |    5 +-
>> drivers/gpu/drm/drm_ioctl.c       |    4 +-
>> drivers/tty/tty_audit.c           |   16 ++--
>> fs/9p/acl.c                       |    8 +-
>> fs/btrfs/acl.c                    |    8 +-
>> fs/configfs/inode.c               |    4 +-
>> fs/debugfs/inode.c                |   26 +++--
>> fs/ext2/acl.c                     |   32 ++++--
>> fs/ext3/acl.c                     |   32 ++++--
>> fs/ext4/acl.c                     |   31 ++++--
>> fs/generic_acl.c                  |    4 +-
>> fs/gfs2/acl.c                     |   14 ++--
>> fs/gfs2/quota.c                   |   44 +++++---
>> fs/jffs2/acl.c                    |    4 +-
>> fs/jfs/acl.c                      |    4 +-
>> fs/jfs/xattr.c                    |    4 +-
>> fs/nfs/nfs3acl.c                  |    4 +-
>> fs/nfsd/vfs.c                     |    8 +-
>> fs/ocfs2/acl.c                    |    4 +-
>> fs/ocfs2/file.c                   |    6 +-
>> fs/ocfs2/quota_global.c           |   34 +++++--
>> fs/ocfs2/quota_local.c            |   12 ++-
>> fs/posix_acl.c                    |   30 +++---
>> fs/proc/base.c                    |   12 ++-
>> fs/quota/dquot.c                  |   43 ++++----
>> fs/quota/netlink.c                |   11 ++-
>> fs/quota/quota.c                  |   44 +++++---
>> fs/quota/quota_tree.c             |   20 +++-
>> fs/quota/quota_v1.c               |    8 +-
>> fs/quota/quota_v2.c               |   14 ++-
>> fs/reiserfs/xattr_acl.c           |    4 +-
>> fs/xattr.c                        |    7 ++
>> fs/xattr_acl.c                    |   96 +++++++++++++++--
>> fs/xfs/xfs_acl.c                  |    4 +-
>> fs/xfs/xfs_quotaops.c             |   18 ++--
>> fs/xfs/xfs_trans_dquot.c          |    8 +-
>
>
> Sorry, maybe I misunderstand something. But I can't find in the patch
> set changes in concrete filesystems' code.

I assume the problem is patches 6 8 13 and 14 didn't make it through to
the mailling for some reason.

Just to see what is going on I you can look at my development branch
git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git userns-always-map-user-v48

Meanwhile I am going to scratch my head and try and resolve my technical
patch sending difficulties.

Eric
