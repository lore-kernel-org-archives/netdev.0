From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] action statistics dumping fix & gnet_stats improvements
Date: Sat, 2 Apr 2005 01:26:54 +0200
Message-ID: <20050401232654.GJ3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes a stupid bug I introduced in the last patchset which for some
reason didn't get caught in the testing process. The other two
patches change the behaviour of yet unused but likely use cases
to what one would expect without reading the code.

Please do a

	bk pull bk://kernel.bkbits.net/tgraf/net-2.6-tcf_exts

This will update the following files:

 include/net/gen_stats.h |    3 ++-
 net/core/gen_stats.c    |   48 +++++++++++++++++++++++++++++++-----------------
 net/sched/act_api.c     |    2 ++
 3 files changed, 35 insertions(+), 18 deletions(-)

through these ChangeSets:

<tgraf@suug.ch> (05/04/01 1.2181.44.3)
   [NET]: Improve gnet_stats_* dumping logic to be less error prone
   
   The recent additions to make gnet_stats_* useable for action
   statistics dumping in two steps introcuded a few error prone
   assumptions which can easly be forgotten. This patch fixes this
   up by simplifying the process of adding new fields to struct
   gnet_dump or adding additional backward compatibility TLVs.
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>
   Signed-off-by: David S. Miller <davem@davemloft.net>

<tgraf@suug.ch> (05/04/01 1.2181.44.2)
   [NET]: Allow dumping of application specific statistics if no primary TLV is used
   
   Although this case is hypothetical at the moment, more advanced actions are
   likely to need this in the future.
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>
   Signed-off-by: David S. Miller <davem@davemloft.net> 

<tgraf@suug.ch> (05/04/01 1.2181.44.1)
   [PKT_SCHED]: Properly return when no backward compatibility action statistics are to be dumped
   
   Fixes a stupid bug introcuded in my "Fix action statistics dumping in
   compatibility mode" patch, no clue why it actually worked without this fix.
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>
   Signed-off-by: David S. Miller <davem@davemloft.net>
