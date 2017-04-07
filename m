From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 00/14] Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:25 +0200
Message-ID: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34514 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755274AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Along the lines of previous patches, switch (almost) all remaining net
drivers to use net_device_stats from net_device instead of including a
copy of it in their netdev_priv struct.

Tobias Klauser (14):
  net: cxgb: Use net_device_stats from struct net_device
  net: cxgb3: Use net_device_stats from struct net_device
  net: dl2k: Use net_device_stats from struct net_device
  net: emac: Use net_device_stats from struct net_device
  net: macb: Use net_device_stats from struct net_device
  net: moxa: Use net_device_stats from struct net_device
  net: nmlan_cs: Use net_device_stats from struct net_device
  net: nuvoton: Use net_device_stats from struct net_device
  net: sunbmac: Use net_device_stats from struct net_device
  net: sunhme: Use net_device_stats from struct net_device
  net: tulip: de2104x: Use net_device_stats from struct net_device
  net: typhoon: Use net_device_stats from struct net_device
  usbnet: kaweth: Use net_device_stats from struct net_device
  usbnet: pegasus: Use net_device_stats from struct net_device

 drivers/net/ethernet/3com/typhoon.c             |  7 ++--
 drivers/net/ethernet/amd/nmclan_cs.c            | 49 ++++++++++++-------------
 drivers/net/ethernet/cadence/macb.c             | 40 ++++++++++----------
 drivers/net/ethernet/cadence/macb.h             |  1 -
 drivers/net/ethernet/chelsio/cxgb/common.h      |  1 -
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c       |  2 +-
 drivers/net/ethernet/chelsio/cxgb3/adapter.h    |  1 -
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c |  2 +-
 drivers/net/ethernet/dec/tulip/de2104x.c        | 42 ++++++++++-----------
 drivers/net/ethernet/dlink/dl2k.c               | 45 ++++++++++-------------
 drivers/net/ethernet/dlink/dl2k.h               |  1 -
 drivers/net/ethernet/ibm/emac/core.c            |  2 +-
 drivers/net/ethernet/ibm/emac/core.h            |  1 -
 drivers/net/ethernet/moxa/moxart_ether.c        | 28 +++++---------
 drivers/net/ethernet/moxa/moxart_ether.h        |  1 -
 drivers/net/ethernet/nuvoton/w90p910_ether.c    | 33 ++++++-----------
 drivers/net/ethernet/sun/sunbmac.c              | 18 ++++-----
 drivers/net/ethernet/sun/sunbmac.h              |  1 -
 drivers/net/ethernet/sun/sunhme.c               | 22 +++++------
 drivers/net/ethernet/sun/sunhme.h               |  2 -
 drivers/net/usb/kaweth.c                        | 32 +++++-----------
 drivers/net/usb/pegasus.c                       | 36 ++++++++----------
 drivers/net/usb/pegasus.h                       |  1 -
 23 files changed, 156 insertions(+), 212 deletions(-)

-- 
2.12.2
