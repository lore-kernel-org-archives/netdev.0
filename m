From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 00] A series of patches to use ARRAY_SIZE in `net' drivers
Date: Mon, 5 Feb 2007 18:54:29 +0200
Message-ID: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:39192 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795AbXBEQye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:54:34 -0500
Received: by an-out-0708.google.com with SMTP id b33so1068769ana
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 08:54:34 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Follows is a sereis of patches to use ARRAY_SIZE macro in drivers/net. 
Patches are sent separately according to their maintaners as replies to 
this thread.

 apne.c                     |    2 +-
 arm/am79c961a.c            |    2 +-
 atarilance.c               |    2 +-
 cs89x0.c                   |    6 +++---
 e1000/e1000_ethtool.c      |    2 +-
 fec_8xx/fec_mii.c          |    4 ++--
 ibm_emac/ibm_emac_debug.c  |    8 ++++----
 irda/actisys-sir.c         |    3 ++-
 ixgb/ixgb_param.c          |    2 +-
 lp486e.c                   |    2 +-
 ne-h8300.c                 |    2 +-
 ne.c                       |    2 +-
 ne2.c                      |    2 +-
 ne2k-pci.c                 |    2 +-
 netxen/netxen_nic_hw.c     |    2 +-
 pcmcia/axnet_cs.c          |    2 +-
 pcmcia/pcnet_cs.c          |    2 +-
 sk98lin/skgemib.c          |    4 +++-
 sk98lin/skgesirq.c         |    3 ++-
 skfp/smt.c                 |    3 ++-
 skfp/srf.c                 |    6 ++++--
 wireless/airo.c            |    4 ++--
 wireless/hostap/hostap.h   |    3 ++-
 wireless/ipw2100.c         |   14 ++++++--------
 wireless/prism54/oid_mgt.c |    4 +++-
 wireless/wavelan.p.h       |    2 +-
 zorro8390.c                |    2 +-
 27 files changed, 50 insertions(+), 42 deletions(-)

Thanks,
-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
