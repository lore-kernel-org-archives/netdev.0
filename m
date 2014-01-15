From: mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
Subject: [PATCH v2 0/2] Add ceph root filesystem functionality and documentation.
Date: Wed, 15 Jan 2014 11:26:27 -0600
Message-ID: <cover.1389806186.git.mark.doffman@codethink.co.uk>
References: <1385000024-23463-1-git-send-email-mark.doffman@codethink.co.uk>
Cc: Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>, sage-4GqslpFJ+cxBDgjK7y7TUQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rob.taylor-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org
To: ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1385000024-23463-1-git-send-email-mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mark Doffman <mark.doffman-4yDnlxn2s6sWdaTGBSpHTA@public.gmane.org>

Hi All,

The following is a second version of a patch series that adds the ability to use
a ceph distributed file system as the root device.

Changes from version 1

fs/ceph/root.c:

The parsing code that takes the DHCP option 17 and kernel command line
parameters has been extensively altered.

The parsing now accepts multiple monitor addresses and ipv6 addresses.

The monitors listed in DHCP option 17 are now concatenated with those
listed on the kernel command line.

The patch series applies to v3.13-rc8-7-g3539717

Thanks

Mark

Mark Doffman (1):
  init: Add a new root device option, the Ceph file system

Rob Taylor (1):
  Documentation: Document the cephroot functionality

 Documentation/filesystems/{ => ceph}/ceph.txt |   0
 Documentation/filesystems/ceph/cephroot.txt   |  86 +++++++++++++
 fs/ceph/Kconfig                               |  10 ++
 fs/ceph/Makefile                              |   1 +
 fs/ceph/root.c                                | 176 ++++++++++++++++++++++++++
 include/linux/ceph/ceph_root.h                |  10 ++
 include/linux/root_dev.h                      |   1 +
 init/do_mounts.c                              |  32 ++++-
 net/ipv4/ipconfig.c                           |  10 +-
 9 files changed, 323 insertions(+), 3 deletions(-)
 rename Documentation/filesystems/{ => ceph}/ceph.txt (100%)
 create mode 100644 Documentation/filesystems/ceph/cephroot.txt
 create mode 100644 fs/ceph/root.c
 create mode 100644 include/linux/ceph/ceph_root.h

-- 
1.8.4

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
