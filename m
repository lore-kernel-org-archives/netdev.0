From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 00/09] net: remove trailing spaces in messages
Date: Wed, 24 Mar 2010 18:40:15 +0100
Message-ID: <201003241840.18701.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, Samuel Ortiz <samuel@sortiz.org>,
	e1000-devel@lists.sourceforge.net, Per Liden <per.liden@ericsson.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	Allan Stephens <allan.stephens@windriver.com>
To: netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is the second patchset to remove trailing spaces in kernel messages. 
Patches in this set cover networking code, excepting wireless which will be 
submitted in a separate set.

Patches have been rebased against current net-next.

Benefits are:
- general cleanup and consistency
- minor reduction in kernel size and user's log file size
- reduced annoyance for people writing logcheck rules

I have run the patches through checkpatch and included some fixes, but in 
most cases the files are so horrible in general that fixing the warnings 
purely for these changes doesn't make sense.

Shortstat:
 56 files changed, 236 insertions(+), 236 deletions(-)

Frans Pop (9):
      net: remove trailing space in messages
      net/tipc: remove trailing space in messages
      net/irda: remove trailing space in messages
      net/ps3_gelic: remove trailing space in messages
      net/smc91xx: remove trailing space in messages
      net/tokenring: remove trailing space in messages
      net/tulip: remove trailing space in messages
      net/intel: remove trailing space in messages
      net/various: remove trailing space in messages

Cheers,
FJP

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
