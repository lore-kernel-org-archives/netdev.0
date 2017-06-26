From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iproute2 0/5] RDMAtool
Date: Mon, 26 Jun 2017 21:21:23 +0300
Message-ID: <20170626182128.24964-1-leon@kernel.org>
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Hi,

This series is implementing the RDAMtool -  the tool to configure RDMA devices.
The initial proposal was sent as RFC [1] and was based on sysfs entries as POC.

The current series was rewritten completely to work with RDMA netlinks as
a source of user<->kernel communications. In order to achieve that, the
RDMA netlinks were extensively refactored and modernized [2, 3 and 4].

The changes from RFC:
1. Removed everything that is not implemented yet.
2. Abandoned sysfs interfaces in favor of netlink.

Available in the "topic/rdmatool-netlink" topic branch of this git repo:
git://git.kernel.org/pub/scm/linux/kernel/git/leon/iproute2.git

Or for browsing:
https://git.kernel.org/cgit/linux/kernel/git/leon/iproute2.git/log/?h=topic/rdmatool-netlink

Thanks

[1] https://www.spinics.net/lists/linux-rdma/msg49575.html
[2] https://patchwork.kernel.org/patch/9752865/
[3] https://www.spinics.net/lists/linux-rdma/msg50827.html
[4] https://www.spinics.net/lists/linux-rdma/msg51210.html

Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Cc: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Cc: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Cc: Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>

Leon Romanovsky (5):
  rdma: Add basic infrastructure for RDMA tool
  rdma: Add dev object
  rdma: Add device capability parsing
  rdma: Add link option and parsing
  rdma: Add initial manual for the tool

 Makefile          |   2 +-
 man/man8/Makefile |   3 +-
 man/man8/rdma.8   |  82 +++++++++++++++
 rdma/.gitignore   |   1 +
 rdma/Makefile     |  22 ++++
 rdma/dev.c        | 140 +++++++++++++++++++++++++
 rdma/link.c       | 201 +++++++++++++++++++++++++++++++++++
 rdma/rdma.c       | 112 ++++++++++++++++++++
 rdma/rdma.h       |  89 ++++++++++++++++
 rdma/utils.c      | 307 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 10 files changed, 957 insertions(+), 2 deletions(-)
 create mode 100644 man/man8/rdma.8
 create mode 100644 rdma/.gitignore
 create mode 100644 rdma/Makefile
 create mode 100644 rdma/dev.c
 create mode 100644 rdma/link.c
 create mode 100644 rdma/rdma.c
 create mode 100644 rdma/rdma.h
 create mode 100644 rdma/utils.c

--
2.13.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
