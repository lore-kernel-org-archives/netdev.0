From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 01/15] userns: Enable building of pf_key sockets when user namespace support is enabled.
Date: Sat, 25 Aug 2012 16:58:14 -0700
Message-ID: <87bohyh6cp.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Enable building of pf_key sockets and user namespace support at the
same time.  This combination builds successfully so there is no reason
to forbid it.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 init/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index b445d6f..448b701 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -944,7 +944,6 @@ config UIDGID_CONVERTED
 	# Networking
 	depends on NET_9P = n
 	depends on AF_RXRPC = n
-	depends on NET_KEY = n
 	depends on DNS_RESOLVER = n
 
 	# Filesystems
-- 
1.7.5.4
