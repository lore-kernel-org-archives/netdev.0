From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 0/3] nfp: port enumeration change and FW ABI adjustment
Date: Tue,  4 Jul 2017 02:27:18 -0700
Message-ID: <20170704092721.780-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33151 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752215AbdGDJ2g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 05:28:36 -0400
Received: by mail-pf0-f178.google.com with SMTP id e7so112837725pfk.0
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 02:28:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set changes the way ports are numbered internally to avoid MAC address
changes and invalid link information when breakout is configured.  Second
patch gets rid of old way of looking up MAC addresses in device information
which caused all this confusion.

Patch 3 is a small adjustment to the new FW ABI version we introduced in
this release cycle.


To clarify these are intended for 4.13, naturally.

Jakub Kicinski (3):
  nfp: improve order of interfaces in breakout mode
  nfp: remove legacy MAC address lookup
  nfp: default to chained metadata prepend format

 drivers/net/ethernet/netronome/nfp/flower/main.c   |  3 +-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |  5 +--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  9 ++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 44 +++++-----------------
 drivers/net/ethernet/netronome/nfp/nfp_port.c      | 14 +++----
 6 files changed, 28 insertions(+), 49 deletions(-)

-- 
2.11.0
