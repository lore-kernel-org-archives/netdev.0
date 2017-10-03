From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH iproute2 0/3] ss: add AF_VSOCK support
Date: Tue,  3 Oct 2017 13:57:41 -0400
Message-ID: <20171003175744.24987-1-stefanha@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35588 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751199AbdJCR5w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 13:57:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds AF_VSOCK support to ss(8).  AF_VSOCK is a host<->guest
communications channel supported by VMware, KVM (virtio-vsock), and Hyper-V.

To dump AF_VSOCK sockets:

  $ ss --vsock

The vsock_diag.ko kernel module for Linux was posted in "[PATCH 0/5] VSOCK: add
sock_diag interface".  That patch series also adds the
<linux/vm_sockets_diag.h> header file that this patch series relies on.  The
Linux patches are also available here:

  https://github.com/stefanha/linux/commits/vsock-diag

Stefan Hajnoczi (3):
  ss: allow AF_FAMILY constants >32
  include: add <linux/vm_sockets_diag.h>
  ss: add AF_VSOCK support

 include/linux/vm_sockets_diag.h |  33 ++++++
 misc/ss.c                       | 238 +++++++++++++++++++++++++++++++++++-----
 man/man8/ss.8                   |   8 +-
 3 files changed, 249 insertions(+), 30 deletions(-)
 create mode 100644 include/linux/vm_sockets_diag.h

-- 
2.13.6
