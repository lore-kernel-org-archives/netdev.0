From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: [PATCH linux1394-2.6.git 00/15] ieee1394: eth1394: cleanups and small
	fixes
Date: Mon, 2 Apr 2007 02:11:56 +0200 (CEST)
Message-ID: <tkrat.7cdc7f6a1e6d9f28@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux1394-devel@lists.sourceforge.net
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
Content-Disposition: INLINE
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

01/15 ieee1394: eth1394: coding style
02/15 ieee1394: eth1394: .probe and .update may sleep
03/15 ieee1394: eth1394: refactor .probe and .update
04/15 ieee1394: eth1394: correct a memset argument
05/15 ieee1394: eth1394: shorter error messages
06/15 ieee1394: eth1394: contain host reset
07/15 ieee1394: eth1394: make MTU configurable
08/15 ieee1394: eth1394: CONFIG_INET is always defined
09/15 ieee1394: eth1394: omit useless set_mac_address callback
10/15 ieee1394: eth1394: don't use alloc_etherdev
11/15 ieee1394: eth1394: clean up fragment_overlap
12/15 ieee1394: eth1394: some conditions are unlikely
13/15 ieee1394: eth1394: hard_start_xmit is called in atomic context
14/15 ieee1394: eth1394: correct return codes in hard_start_xmit
15/15 ieee1394: eth1394: check for kmem_cache_create failure

 drivers/ieee1394/eth1394.c |  603 ++++++++++++++++---------------------
 drivers/ieee1394/eth1394.h |   24 -
 2 files changed, 268 insertions(+), 359 deletions(-)

-- 
Stefan Richter
-=====-=-=== -=-- ---=-
http://arcgraph.de/sr/


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
