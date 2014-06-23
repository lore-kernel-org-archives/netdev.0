From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] crc32 combine improvements
Date: Mon, 23 Jun 2014 15:11:53 +0200
Message-ID: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux@horizon.com,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So almost a month passed, and I don't want this to get lost
somewhere. I have applied the feedback given at that time to
this set, rebased plus tested it against latest net-next. I
decided to route this via netdev as it improves performance
upon library code that provides library bits for SCTP, i.e.
for non-linear skb csum handling in IPVS. Thus, resending
this for George before it gets lost.

Thanks!

George Spelvin (3):
  lib: crc32: Greatly shrink CRC combining code
  lib: crc32: Mark test data __initconst
  lib: crc32: Add some additional __pure annotations

 include/linux/crc32.h |  20 +++++--
 lib/crc32.c           | 153 ++++++++++++++++++++++++--------------------------
 2 files changed, 88 insertions(+), 85 deletions(-)

-- 
1.7.11.7
