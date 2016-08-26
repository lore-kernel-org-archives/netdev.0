From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/3] sfc: minor fixes
Date: Fri, 26 Aug 2016 15:11:34 +0100
Message-ID: <da7f8a31-f24c-7727-7d78-67572f5494d5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:18870 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751449AbcHZOT6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:19:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Edward Cree (2):
  sfc: include size-binned TX stats on sfn8542q
  sfc: remove duplicate assignment

Jon Cooper (1):
  sfc: work around TRIGGER_INTERRUPT command not working on SFC9140

 drivers/net/ethernet/sfc/ef10.c       | 25 +++++++++++++++++--------
 drivers/net/ethernet/sfc/farch.c      |  3 ++-
 drivers/net/ethernet/sfc/net_driver.h |  2 +-
 drivers/net/ethernet/sfc/nic.c        |  4 ++--
 drivers/net/ethernet/sfc/nic.h        |  4 ++--
 drivers/net/ethernet/sfc/selftest.c   | 10 +++++++++-
 drivers/net/ethernet/sfc/selftest.h   |  2 +-
 7 files changed, 34 insertions(+), 16 deletions(-)
