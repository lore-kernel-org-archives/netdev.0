From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net ax25: Fix the build when sysctl support is disabled.
Date: Mon, 23 Apr 2012 17:25:49 -0700
Message-ID: <m1obqirn5e.fsf_-_@fess.ebiederm.org>
References: <20120423170701.c96e402234b1387dece11dda@canb.auug.org.au>
	<4F95828A.8050403@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Randy Dunlap <rdunlap@xenotime.net>
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4F95828A.8050403@xenotime.net> (Randy Dunlap's message of "Mon,
	23 Apr 2012 09:25:46 -0700")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Randy Dunlap <rdunlap@xenotime.net> reported:

> On 04/23/2012 12:07 AM, Stephen Rothwell wrote:
>
>> Hi all,
>>
>> Changes since 20120420:
>
>
> include/net/ax25.h:447:75: error: expected ';' before '}' token
>
> static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
> static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
>
> First function:  move ';' inside braces.
> Second function:  drop the ';'.

Put the semicolons where it makes sense.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---

Resent to include David Miller.

 include/net/ax25.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ax25.h b/include/net/ax25.h
index 8a7a122..5d23521 100644
--- a/include/net/ax25.h
+++ b/include/net/ax25.h
@@ -444,8 +444,8 @@ extern void ax25_uid_free(void);
 extern int ax25_register_dev_sysctl(ax25_dev *ax25_dev);
 extern void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev);
 #else
-static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0 };
-static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {};
+static inline int ax25_register_dev_sysctl(ax25_dev *ax25_dev) { return 0; }
+static inline void ax25_unregister_dev_sysctl(ax25_dev *ax25_dev) {}
 #endif /* CONFIG_SYSCTL */
 
 #endif
-- 
1.7.2.5
