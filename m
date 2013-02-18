From: Andy King <acking@vmware.com>
Subject: [PATCH 0/4] Minor vSockets fixes
Date: Mon, 18 Feb 2013 08:04:09 -0800
Message-ID: <1361203453-1347-1-git-send-email-acking@vmware.com>
Cc: davem@davemloft.net, pv-drivers@vmware.com, kraxel@redhat.com,
	Andy King <acking@vmware.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Minor vSockets fixes, two of which were reported on LKML.

Andy King (2):
  VSOCK: Remove hypervisor-only socket option
  VSOCK: Don't reject PF_VSOCK protocol

Dmitry Torokhov (2):
  VSOCK: get rid of EXPORT_SYMTAB
  VSOCK: get rid of vsock_version.h

 include/uapi/linux/vm_sockets.h |    8 --------
 net/vmw_vsock/af_vsock.c        |    7 ++-----
 net/vmw_vsock/vmci_transport.c  |    2 --
 net/vmw_vsock/vsock_version.h   |   22 ----------------------
 4 files changed, 2 insertions(+), 37 deletions(-)
 delete mode 100644 net/vmw_vsock/vsock_version.h

-- 
1.7.4.1
