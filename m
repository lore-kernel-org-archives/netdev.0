From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next-2.6 0/3] vhost_net
Date: Thu, 14 Jan 2010 18:16:59 +0200
Message-ID: <20100114161659.GA28159@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org,
	"virtualization@lists.linux-foundation.org Michael S. Tsirkin"
	<mst@redhat.com>, Herbert Xu <herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37899 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751056Ab0ANQUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 11:20:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches have been sitting in Rusty's tree and linux-next for a
couple of kernel releases already, they are largely unchanged since
November, besides a couple of bugfixes.  They got Rusty's blessing,
and I'd like them to go into net-next-2.6 and then 2.6.34.

The patchset is aganst net-next-2.6, commit 508e14b4a4fb1a824a14f2c5b8d7df67b313f8e4.

Thanks!


Michael S. Tsirkin (3):
  tun: export underlying socket
  mm: export use_mm/unuse_mm to modules
  vhost_net: a kernel-level virtio server

 MAINTAINERS                |    9 +
 arch/ia64/kvm/Kconfig      |    1 +
 arch/powerpc/kvm/Kconfig   |    1 +
 arch/s390/kvm/Kconfig      |    1 +
 arch/x86/kvm/Kconfig       |    1 +
 drivers/Makefile           |    1 +
 drivers/net/tun.c          |  101 ++++-
 drivers/vhost/Kconfig      |   11 +
 drivers/vhost/Makefile     |    2 +
 drivers/vhost/net.c        |  661 ++++++++++++++++++++++++++
 drivers/vhost/vhost.c      | 1098 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h      |  161 +++++++
 include/linux/Kbuild       |    1 +
 include/linux/if_tun.h     |   14 +
 include/linux/miscdevice.h |    1 +
 include/linux/vhost.h      |  130 ++++++
 mm/mmu_context.c           |    3 +
 17 files changed, 2178 insertions(+), 19 deletions(-)
 create mode 100644 drivers/vhost/Kconfig
 create mode 100644 drivers/vhost/Makefile
 create mode 100644 drivers/vhost/net.c
 create mode 100644 drivers/vhost/vhost.c
 create mode 100644 drivers/vhost/vhost.h
 create mode 100644 include/linux/vhost.h
