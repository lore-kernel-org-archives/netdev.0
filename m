From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/3] ethtool: support for forward error correction mode setting on a link
Date: Sat, 24 Jun 2017 12:19:42 -0700
Message-ID: <1498331985-8525-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, vidya.chowdary@gmail.com,
        dustin@cumulusnetworks.com, olson@cumulusnetworks.com,
        leedom@chelsio.com, manojmalviya@chelsio.com, santosh@chelsio.com,
        yuval.mintz@qlogic.com, odedw@mellanox.com, ariela@mellanox.com,
        galp@mellanox.com, jeffrey.t.kirsher@intel.com
To: davem@davemloft.net, linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33811 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751482AbdFXTTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2017 15:19:54 -0400
Received: by mail-pg0-f54.google.com with SMTP id e187so33406712pgc.1
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2017 12:19:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Forward Error Correction (FEC) modes i.e Base-R
and Reed-Solomon modes are introduced in 25G/40G/100G standards
for providing good BER at high speeds. Various networking devices
which support 25G/40G/100G provides ability to manage supported FEC
modes and the lack of FEC encoding control and reporting today is a
source for itneroperability issues for many vendors.
FEC capability as well as specific FEC mode i.e. Base-R
or RS modes can be requested or advertised through bits D44:47 of base link
codeword.

This patch set intends to provide option under ethtool to manage and report
FEC encoding settings for networking devices as per IEEE 802.3 bj, bm and by
specs.

Casey Leedom (2):
  cxgb4: core hardware/firmware support for Forward Error Correction on
    a link
  cxgb4: ethtool forward error correction management support

Vidya Sagar Ravipati (1):
  net: ethtool: add support for forward error correction modes

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  99 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 151 ++++++++++++++++-----
 include/linux/ethtool.h                            |   4 +
 include/uapi/linux/ethtool.h                       |  48 ++++++-
 net/core/ethtool.c                                 |  34 +++++
 5 files changed, 300 insertions(+), 36 deletions(-)

-- 
2.1.4
