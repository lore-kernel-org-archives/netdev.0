From: Mike Waychison <mikew@google.com>
Subject: [PATCH v3 17/22] kmsg_dumper: Introduce a new 'SOFT' dump reason
Date: Tue, 14 Dec 2010 13:30:27 -0800
Message-ID: <20101214213026.17022.26883.stgit@mike.mtv.corp.google.com>
References: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: adurbin@google.com, linux-kernel@vger.kernel.org,
	chavey@google.com, Greg KH <greg@kroah.com>,
	netdev@vger.kernel.org,
	=?utf-8?q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	akpm@linux-foundation.org, linux-api@vger.kernel.org
To: simon.kagstrom@netinsight.net, davem@davemloft.net,
	nhorman@tuxdriver.com, Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101214212846.17022.64836.stgit@mike.mtv.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is a useful to be able to exercise kmsg_dumper implementations without
requiring a kernel oops or panic.  This commit adds a new reason called
KMSG_DUMP_SOFT, which signifies that the system isn't really going down.

This logic is used in a later commit that introduces the netoops driver.

Signed-off-by: Mike Waychison <mikew@google.com>
---
Notes:

It is also possible that we not introduce KMSG_DUMP_SOFT, and simply overload
the existing KMSG_DUMP_OOPS reason, but I figured that this would be cleaner.
---
 include/linux/kmsg_dump.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/kmsg_dump.h b/include/linux/kmsg_dump.h
index a229acc..0abc2d7 100644
--- a/include/linux/kmsg_dump.h
+++ b/include/linux/kmsg_dump.h
@@ -20,6 +20,7 @@ enum kmsg_dump_reason {
 	KMSG_DUMP_OOPS,
 	KMSG_DUMP_PANIC,
 	KMSG_DUMP_KEXEC,
+	KMSG_DUMP_SOFT,
 };
 
 /**
