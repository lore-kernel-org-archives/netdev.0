From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH 0/2] siw: Fix build failure for > v2.6.34 + add crc32c-intel.ko offload
Date: Wed, 22 Sep 2010 13:30:08 -0700
Message-ID: <1285187408-10905-1-git-send-email-nab@linux-iscsi.org>
Cc: David Miller <davem@davemloft.net>,
	Matthew Wilcox <willy@linux.intel.com>,
	Andi Keen <ak@linux.intel.com>,
	Roland Dreier <rdreier@cisco.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Bellinger <nab@linux-iscsi.org>

Greetings Bernard and NetDev folks,

Attached are two patches for softiwarp/kernel.git, the first of which fixes a build
failure on > v2.6.34 kernels with ib_register_device(), and the second is the addition
of proper support for libcrypto crc32c-intel.ko using Nehalem SSE v4.2 instruction offload
which is an item that has been recently added into our LIO-Target v4.0.0-rc4 release
over on the linux-scsi list.

Please note that this code has only been compile tested so far, but I do plan to have
a deeper look at your teams work once I have a bit more free time on my hands.

Many great thanks for all of your efforts with IBM Software iWARP stack!

Signed-off-by: Nicholas A. Bellinger <nab@linux-iscsi.org>

Nicholas Bellinger (2):
  siw: Fix ib_register_device() for > v2.6.34 kernels
  siw: Add support for CRC32C offload instruction using libcrypto
    crc32c-intel

 softiwarp/siw_main.c  |    5 ++++-
 softiwarp/siw_verbs.c |   37 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 40 insertions(+), 2 deletions(-)
