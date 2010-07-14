From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 00/11] Removing dead code
Date: Wed, 14 Jul 2010 14:39:29 +0200
Message-ID: <cover.1279110894.git.siccegge__3162.20946047014$1279111196$gmane$org@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43507 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553Ab0GNMjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:39:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all!
       
        As part of the VAMOS[0] research project at the University of
Erlangen we are looking at multiple integrity errors in linux'
configuration system.

        I've been running a check on the drivers/net sourcetree for
config Items not defined in Kconfig and found 11 such
cases. Sourcecode blocks depending on these Items are not reachable
from a vanilla kernel -- dead code. I've seen such dead blocks made on
purpose e.g. while integrating new features into the kernel but
generally they're just useless.

        Each of the patches in this patchset removes on such dead
config Item, I'd be glad if you consider applying them. I've been
doing deeper analysis of such issues before and can do so again but
I'm not so sure they were fastly usefull.

        I build the patches against a vanilla kernel in order to
try if the kernel compiles with this patches

        Please keep me informed of this patch getting confirmed /
merged so we can keep track of it.

Regards

        Christoph Egger

[0] http://vamos1.informatik.uni-erlangen.de/

Christoph Egger (11):
  Removing dead RT2800PCI_SOC
  Removing dead {AR,WAVE}LAN
  Removing dead CASSINI_QGE_DEBUG
  Removing dead CASSINI_MULTICAST_REG_WRITE
  Removing dead CASSINI_NAPI
  Removing dead CHELSIO_T1_COUGAR
  Removing dead ARCH_PNX010X
  Removing dead SH_HICOSH4
  Removing dead ETRAX_NETWORK_RED_ON_NO_CONNECTION
  Removing dead NETWINDER_{T,R}X_DMA_PROBLEMS
  Removing dead REDWOOD_{5,6}

 drivers/net/Space.c                     |    6 --
 drivers/net/cassini.c                   |   25 +--------
 drivers/net/cassini.h                   |    4 -
 drivers/net/chelsio/subr.c              |   48 +---------------
 drivers/net/cris/eth_v10.c              |    4 -
 drivers/net/cs89x0.c                    |   96 +------------------------------
 drivers/net/cs89x0.h                    |    4 -
 drivers/net/irda/w83977af_ir.c          |   33 +---------
 drivers/net/smc91x.h                    |   37 ------------
 drivers/net/wireless/rt2x00/Kconfig     |    5 --
 drivers/net/wireless/rt2x00/rt2800pci.c |   39 -------------
 11 files changed, 9 insertions(+), 292 deletions(-)

