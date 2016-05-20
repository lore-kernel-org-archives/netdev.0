From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v3.13.y-ckt][PATCH 0/1] bridge: notify user space
	after fdb update
Date: Fri, 20 May 2016 12:59:36 -0400
Message-ID: <cover.1463760264.git.joseph.salisbury__41629.54737335$1463943561$gmane$org@canonical.com>
Cc: jiri@resnulli.us, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	jmaxwell37@gmail.com, davem@davemloft.net
To: kamal.mostafa@canonical.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

BugLink: http://bugs.launchpad.net/bugs/1581585

Hello,

Please consider including upstream commit c65c7a306610ee7c13669a8f5601b472c19dc6f1
in the next v3.13.y-ckt release.  It was included in the mainline tree as of 
v3.14-rc3.  It has been tested and confirmed to resolve
http://bugs.launchpad.net/bugs/1581585 .

This commit also reques commit a5642ab4744 as a prereq.  Commit  a5642ab4744 
does not apply cleanly to v3.13-y.ckt, so I performed a backport, which is
in email 1/1


Prereq:
commit a5642ab4744bc8c5a8c7ce7c6e30c01bd6bbc691
Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date:   Fri Feb 7 16:48:18 2014 +0900

    bridge: Fix the way to find old local fdb entries in br_fdb_changeaddr

Real fix:
commit c65c7a306610ee7c13669a8f5601b472c19dc6f1
Author: Jon Maxwell <jmaxwell37@gmail.com>
Date:   Thu May 29 17:27:16 2014 +1000

    bridge: notify user space after fdb update

Regards,

Joe Salisbury
