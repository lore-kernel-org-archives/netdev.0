From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/15] mlxsw: Driver update, cleanups
Date: Thu, 15 Oct 2015 17:43:14 +0200
Message-ID: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33926 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753486AbbJOPnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:32 -0400
Received: by qkfm62 with SMTP id m62so38783290qkf.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset contains various cleanups and improvements in mlxsw driver.

Ido Schimmel (5):
  mlxsw: Remove multicast ID configuration
  mlxsw: reg: Adjust definition of enum mlxsw_reg_sfgc_type
  mlxsw: Simplify traps creation
  mlxsw: Add trap group for control packets
  mlxsw: cmd: Update CONFIG_PROFILE command documentation

Jiri Pirko (10):
  mlxsw: switchx2: Use ETH_ALEN for mac address length
  mlxsw: pci: Use MLXSW_PCI_CQS_MAX instead of MLXSW_PCI_CQS_COUNT
  mlxsw: pci: Do not use MLXSW_PCI_SDQS_COUNT define
  mlxsw: pci: Remove MLXSW_PCI_RDQS/SDQS defines and checks
  mlxsw: pci: Limit number of entries being sent in single MAP_FA cmd
  mlxsw: core: Do not use EMADs in mlxsw_emad_fini
  mlxsw: Use dev_level_ratelimited instead of net_ratelimit & dev_level
  mlxsw: reg: Uppercase letters in register IDs
  mlxsw: reg: Remove extra space in SFGC ID define
  mlxsw: Introduce mlxsw_reg_spms_vid_pack helper and use it

 drivers/net/ethernet/mellanox/mlxsw/cmd.h      |  26 +++---
 drivers/net/ethernet/mellanox/mlxsw/core.c     |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c      |  49 ++++++----
 drivers/net/ethernet/mellanox/mlxsw/pci.h      |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 121 ++++++++++---------------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c |  34 +++----
 6 files changed, 103 insertions(+), 134 deletions(-)

-- 
1.9.3
