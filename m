From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net-next v3 0/3] net: finish renaming lls to
	busy poll
Date: Wed, 10 Jul 2013 17:13:07 +0300
Message-ID: <20130710141307.15596.47242.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb@google.com>, Jonathan Corbet <corbet@lwn.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	Eliezer Tamir <eliezer@tamir.org.il>,
	Eilon Greenstein <eilong@broadcom.com>, Eric Dumazet <erdnetdev@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

David,

Here are three patches that complete the rename of lls to busy-poll

1. rename include/net/ll_poll.h to include/net/busy_poll.h
2. Rename ndo_ll_poll to ndo_busy_poll.
   Rename sk_mark_ll to sk_mark_napi_id.
   Rename skb_mark_ll to skb_mark_napi_id.
   Correct all useres of these functions.
   Update comments and defines  in include/net/busy_poll.h
3. Rename LL_SO to BUSY_POLL_SO
   Rename sysctl_net_ll_{read,poll} to sysctl_busy_{read,poll}
   Fix up users of these variables.
   Fix documentation for sysctl.

v2 fixed forgetting the ndo changes in v1
v3 is a resend with -M

-Eliezer

------------------------------------------------------------------------------
See everything from the browser to the database with AppDynamics
Get end-to-end visibility with application monitoring from AppDynamics
Isolate bottlenecks and diagnose root cause in seconds.
Start your free trial of AppDynamics Pro today!
http://pubads.g.doubleclick.net/gampad/clk?id=48808831&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
