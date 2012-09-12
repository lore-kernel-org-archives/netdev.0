From: Joe Perches <joe@perches.com>
Subject: [PATCH] CodingStyle: Add networking specific block comment style
Date: Tue, 11 Sep 2012 20:11:21 -0700
Message-ID: <1347419481.2456.10.camel@joe2Laptop>
References: <1347410853.2456.7.camel@joe2Laptop>
	 <804857E1F29AAC47BF68C404FC60A1842EB021D9@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Andy Whitcroft <apw@canonical.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <804857E1F29AAC47BF68C404FC60A1842EB021D9@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The block comment style in net/ and drivers/net is non-standard.
Document it.

Signed-off-by: Joe Perches <joe@perches.com>
---
> This conflicts with the preferred style for long (multi-line) comments documented in
> ./Documentation/CodingStyle.  If this is the way comments should be done in the
> networking code this patch should also include an update to Chapter 8 in CodingStyle
> documenting the networking specific style to avoid confusion.

 Documentation/CodingStyle |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/Documentation/CodingStyle b/Documentation/CodingStyle
index cb9258b..495e5ba 100644
--- a/Documentation/CodingStyle
+++ b/Documentation/CodingStyle
@@ -454,6 +454,16 @@ The preferred style for long (multi-line) comments is:
 	 * with beginning and ending almost-blank lines.
 	 */
 
+For files in net/ and drivers/net/ the preferred style for long (multi-line)
+comments is a little different.
+
+	/* The preferred comment style for files in net/ and drivers/net
+	 * looks like this.
+	 *
+	 * It is nearly the same as the generally preferred comment style,
+	 * but there is no initial almost-blank line.
+	 */
+
 It's also important to comment data, whether they are basic types or derived
 types.  To this end, use just one data declaration per line (no commas for
 multiple data declarations).  This leaves you room for a small comment on each
