From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/4] nfp: devlink port implementation
Date: Tue, 23 May 2017 08:12:43 -0700
Message-ID: <20170523151247.8535-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34287 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764384AbdEWPNL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 11:13:11 -0400
Received: by mail-pf0-f171.google.com with SMTP id 9so117571937pfj.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 08:13:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series adds basic devlink support.  The operations we can perfrom
are port show and port split/unsplit.

Jakub Kicinski (3):
  nfp: register ports as devlink ports
  nfp: calculate total port lanes for split
  nfp: support port splitting via devlink

Simon Horman (1):
  nfp: add devlink support

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_devlink.c   | 185 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  30 +++-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   5 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  57 ++++++-
 drivers/net/ethernet/netronome/nfp/nfp_port.c      |  19 +++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  12 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |   3 +
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_eth.c   |  11 +-
 9 files changed, 307 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_devlink.c

-- 
2.11.0
