From: Matt Mackall <mpm@selenic.com>
Subject: Re: [2.6.24-mm1] TCP/IPv6 connect() oopses at
	twothirdsMD4Transform()
Date: Mon, 04 Feb 2008 20:30:00 -0600
Message-ID: <1202178600.17934.165.camel@cinder.waste.org>
References: <200802050128.m151ShPX088549@www262.sakura.ne.jp>
	 <20080204173652.0fbe8885.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Theodore Ts'o" <tytso@mit.edu>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:37550 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbYBECbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 21:31:16 -0500
In-Reply-To: <20080204173652.0fbe8885.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-02-04 at 17:36 -0800, Andrew Morton wrote:
> On Tue, 05 Feb 2008 10:28:43 +0900 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp> wrote:
> 
> > Hello.
> > 
> > Kernel config is at http://I-love.SAKURA.ne.jp/tmp/config-2.6.24-mm1
> > 
> > 2.6.24 works fine.

> err, Matt?

random: revert braindamage that snuck into checkpatch cleanup

Signed-off-by: Matt Mackall <mpm@selenic.com>

diff -r 50a6e531a9f2 drivers/char/random.c
--- a/drivers/char/random.c	Mon Feb 04 20:23:02 2008 -0600
+++ b/drivers/char/random.c	Mon Feb 04 20:28:08 2008 -0600
@@ -1306,7 +1306,7 @@
  * Rotation is separate from addition to prevent recomputation
  */
 #define ROUND(f, a, b, c, d, x, s)	\
-	(a += f(b, c, d) + in[x], a = (a << s) | (a >> (32 - s)))
+	(a += f(b, c, d) + x, a = (a << s) | (a >> (32 - s)))
 #define K1 0
 #define K2 013240474631UL
 #define K3 015666365641UL

-- 
Mathematics is the supreme nostalgia of our time.

