From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] lib: crc32: Mark test data __initconst
Date: Mon, 23 Jun 2014 15:11:55 +0200
Message-ID: <1403529116-18385-3-git-send-email-dborkman@redhat.com>
References: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux@horizon.com,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403529116-18385-1-git-send-email-dborkman@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin <linux@horizon.com>

So it gets discarded after the selftest.

Signed-off-by: George Spelvin <linux@horizon.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/crc32.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/crc32.c b/lib/crc32.c
index 9af30ff..af938ab 100644
--- a/lib/crc32.c
+++ b/lib/crc32.c
@@ -344,7 +344,7 @@ EXPORT_SYMBOL(crc32_be);
 #ifdef CONFIG_CRC32_SELFTEST
 
 /* 4096 random bytes */
-static u8 __attribute__((__aligned__(8))) test_buf[] =
+static u8 const __aligned(8) test_buf[] __initconst =
 {
 	0x5b, 0x85, 0x21, 0xcb, 0x09, 0x68, 0x7d, 0x30,
 	0xc7, 0x69, 0xd7, 0x30, 0x92, 0xde, 0x59, 0xe4,
@@ -868,7 +868,7 @@ static struct crc_test {
 	u32 crc_le;	/* expected crc32_le result */
 	u32 crc_be;	/* expected crc32_be result */
 	u32 crc32c_le;	/* expected crc32c_le result */
-} test[] =
+} const test[] __initconst =
 {
 	{0x674bf11d, 0x00000038, 0x00000542, 0x0af6d466, 0xd8b6e4c1, 0xf6e93d6c},
 	{0x35c672c6, 0x0000003a, 0x000001aa, 0xc6d3dfba, 0x28aaf3ad, 0x0fe92aca},
-- 
1.7.11.7
