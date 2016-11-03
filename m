From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: enable 4-tuple UDP RSS hashing
Date: Thu, 3 Nov 2016 22:10:31 +0000
Message-ID: <ba5aa0bc-277b-5b47-89f8-fad1010b77f9@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <linux-net-drivers@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:9017 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932973AbcKCWKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 18:10:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EF10 based NICs have configurable RSS hash fields, and can be made to take the
ports into the hash on UDP (they already do so for TCP).  This patch series
enables this, in order to improve spreading of UDP traffic.

Edward Cree (2):
  sfc: enable 4-tuple RSS hashing for UDP
  sfc: report 4-tuple UDP hashing to ethtool, if it's enabled

 drivers/net/ethernet/sfc/ef10.c       | 84 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/sfc/ethtool.c    | 12 +++--
 drivers/net/ethernet/sfc/net_driver.h |  2 +
 3 files changed, 94 insertions(+), 4 deletions(-)
