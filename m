From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH 0/4] firewire-net updates
Date: Sun, 7 Nov 2010 22:38:20 +0100 (CET)
Message-ID: <tkrat.036c5d10fb83f85d@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Here is a repost of yesterday's patches for firewire-net.  I dropped the
error logging limitation.

firewire: net: count stats.tx_packets and stats.tx_bytes
firewire: net: fix memory leaks
firewire: net: replace lists by counters
firewire: net: throttle TX queue before running out of tlabels

 drivers/firewire/net.c |  137 ++++++++++++++++++++++++-----------------
 1 file changed, 83 insertions(+), 54 deletions(-)
-- 
Stefan Richter
-=====-==-=- =-== --===
http://arcgraph.de/sr/



------------------------------------------------------------------------------
The Next 800 Companies to Lead America's Growth: New Video Whitepaper
David G. Thomson, author of the best-selling book "Blueprint to a 
Billion" shares his insights and actions to help propel your 
business during the next growth cycle. Listen Now!
http://p.sf.net/sfu/SAP-dev2dev
