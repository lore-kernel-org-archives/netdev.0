From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] IFF_RUNNING related fixes
Date: Mon, 28 Mar 2005 02:06:10 +0200
Message-ID: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fixes various drivers still relying on IFF_RUNNING. I don't have
any of these cards so all patches completely untested.

Unresolved broken users of IFF_RUNNING are:

  drivers/wan/syncppp.c
     The stats update based on IFF_RUNNING has been broken
     for a long time. I'm not sure whether it should be
     changed to check netif_running or carrier_ok so I
     left it as-is for now.

  drivers/s390/net/*
     Various usages I'm not sure about the intention of the
     original code. Authors contacted but no reply so far.

Please do a

	bk pull bk://kernel.bkbits.net/tgraf/netdev-2.6-iff_running

This will update the following files:

 drivers/net/au1000_eth.c       |   10 ++--------
 drivers/net/bmac.c             |    2 --
 drivers/net/sk98lin/skge.c     |    8 +++-----
 drivers/net/tlan.c             |    4 ++--
 drivers/net/tokenring/ibmtr.c  |   11 +++--------
 drivers/net/wan/lmc/lmc_main.c |    8 ++------
 include/linux/if.h             |    2 +-
 7 files changed, 13 insertions(+), 32 deletions(-)

through these ChangeSets:

<tgraf@suug.ch> (05/03/28 1.2039)
   [NET]: Change comment to describe the real meaning of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2038)
   [sk98lin]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2037)
   [ibmtr]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2036)
   [lmc]: Use netif_carrier_* instead of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2035)
   [tlan]: Use netif_carrier_* intead of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2034)
   [bmac]: Remove obsolete usage of IFF_RUNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>

<tgraf@suug.ch> (05/03/28 1.2033)
   [au1000]: Use netif_carrier_* instead of IFF_RUNNING
   
   Signed-off-by: Thomas Graf <tgraf@suug.ch>
