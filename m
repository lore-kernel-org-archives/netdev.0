From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] mlxsw: Add support for cable info access
Date: Wed, 14 Jun 2017 09:27:38 +0200
Message-ID: <20170614072740.1243-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35721 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754223AbdFNH1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 03:27:43 -0400
Received: by mail-wr0-f195.google.com with SMTP id z45so6100976wrb.2
        for <netdev@vger.kernel.org>; Wed, 14 Jun 2017 00:27:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add support for cable info access via ethtool. This is done by accessing
the SFP+/QSFP internal EEPROM.

Arkadi Sharshevsky (2):
  mlxsw: reg: Add MCIA register for cable info access
  mlxsw: spectrum: Add support for access cable info via ethtool

 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  76 ++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 131 +++++++++++++++++++++++++
 2 files changed, 207 insertions(+)

-- 
2.9.3
