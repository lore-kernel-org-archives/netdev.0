From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][v3.2.y]  inetpeer: Invalidate the inetpeer tree along with
 the routing cache
Date: Tue, 20 Aug 2013 13:34:51 -0400
Message-ID: <5213A8BB.5070309@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Please consider including mainline commit 5faa5df in the next v3.2.y
release.  It was included in the mainline tree as of v3.3-rc7.  It has
been tested and confirmed to resolve
http://bugs.launchpad.net/bugs/1205741 .


commit 5faa5df1fa2024bd750089ff21dcc4191798263d
Author: Steffen Klassert <steffen.klassert@secunet.com>
Date:   Tue Mar 6 21:20:26 2012 +0000

    inetpeer: Invalidate the inetpeer tree along with the routing cache


Also note that commit 5faa5df introduced a race condition that is fixed
by mainline commit 55432d2, so that commit would also be required:

commit 55432d2b543a4b6dfae54f5c432a566877a85d90
Author: Eric Dumazet <edumazet@google.com>
Date:   Tue Jun 5 03:00:18 2012 +0000

    inetpeer: fix a race in inetpeer_gc_worker()



Sincerely,
Joseph Salisbury
