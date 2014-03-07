From: Joe Perches <joe@perches.com>
Subject: [PATCH] checkpatch: Always warn on missing blank line after
 variable declaration block
Date: Thu, 06 Mar 2014 16:11:01 -0800
Message-ID: <1394151061.16156.16.camel@joe-AO722>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
 <1394104390-23477-1-git-send-email-kys@microsoft.com>
 <20140306.142919.763823800315842610.davem@davemloft.net>
 <1394148520.16156.8.camel@joe-AO722>
 <20140306153530.bd61c160ba6f7872d6967b2e@linux-foundation.org>
 <1394149350.16156.13.camel@joe-AO722>
 <20140306155517.0b3976316b0335d16ab25e38@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140306155517.0b3976316b0335d16ab25e38@linux-foundation.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Make the test system wide, modify the message too.

Signed-off-by: Joe Perches <joe@perches.com>
---
> OK, let's do this for now.  Could you please cook up a followon patch
> which makes this kernel-wide?  I'll play with that for a while then I'll
> decide how much I feel like irritating people.

 scripts/checkpatch.pl | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index a6e3048..37a94f1 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -2249,8 +2249,7 @@ sub process {
 		}
 
 # check for missing blank lines after declarations
-		if ($realfile =~ m@^(drivers/net/|net/)@ &&
-		    $prevline =~ /^\+\s+$Declare\s+$Ident/ &&
+		if ($prevline =~ /^\+\s+$Declare\s+$Ident/ &&
 		    !($prevline =~ /(?:$Compare|$Assignment|$Operators)\s*$/ ||
 		      $prevline =~ /(?:\{\s*|\\)$/) &&		#extended lines
 		    $sline =~ /^\+\s+/ &&			#Not at char 1
@@ -2260,7 +2259,7 @@ sub process {
 		      $sline =~ /^\+\s+(?:$|[\{\}\.\#\"\?\:\(])/ ||
 		      $sline =~ /^\+\s+\(?\s*(?:$Compare|$Assignment|$Operators)/)) {
 			WARN("SPACING",
-			     "networking uses a blank line after declarations\n" . $hereprev);
+			     "Missing a blank line after declarations\n" . $hereprev);
 		}
 
 # check for spaces at the beginning of a line.
