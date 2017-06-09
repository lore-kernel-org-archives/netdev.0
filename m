From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/5] nfp: FW app build name reporting
Date: Thu,  8 Jun 2017 20:56:09 -0700
Message-ID: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36848 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbdFID5y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 23:57:54 -0400
Received: by mail-pf0-f176.google.com with SMTP id x63so23887626pff.3
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 20:57:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds reporting FW build name in ethtool -i.  Most
of the patches are restructuring where information caching is
done.  There is also a minor error path fix.

These are last few patches finishing the basic nfp_app support.


Jakub Kicinski (5):
  nfp: make sure to cancel port refresh on the error path
  nfp: remove automatic caching of RTsym table
  nfp: remove automatic caching of HWInfo
  nfp: keep MIP object around
  nfp: report application FW build name in ethtool -i

 drivers/net/ethernet/netronome/nfp/nfp_app.c       |   8 ++
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |   2 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  29 +++--
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  11 +-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |   4 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  17 +--
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   4 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_cpp.h   |   7 --
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   |  43 -------
 .../ethernet/netronome/nfp/nfpcore/nfp_hwinfo.c    |  70 +++++-------
 .../net/ethernet/netronome/nfp/nfpcore/nfp_mip.c   |   7 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |  16 ++-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |   8 +-
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c | 127 +++++++++------------
 15 files changed, 158 insertions(+), 196 deletions(-)

-- 
2.11.0
