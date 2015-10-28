From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/12] mlxsw: driver update
Date: Wed, 28 Oct 2015 10:16:53 +0100
Message-ID: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35658 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516AbbJ1JXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:23:55 -0400
Received: by wmll128 with SMTP id l128so5286528wml.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:23:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This driver update mainly brings support for user to be able to setup
flooding on specified port, via bridge flag. Also, there is a fix in ageing
time conversion. The rest is just cosmetics.

Ido Schimmel (4):
  switchdev: Add support for flood control
  switchdev: Make flood to CPU optional
  mlxsw: spectrum: Add support for VLAN ranges in flooding configuration
  mlxsw: spectrum: Add support for flood control

Jiri Pirko (6):
  mlxsw: spectrum: move "bridged" bool to u8 flags
  mlxsw: reg: Fix description for reg_sfd_uc_sub_port
  mlxsw: reg: Fix desription typos of couple of SFN items
  mlxsw: reg: Avoid unnecessary line wrap for mlxsw_reg_sfd_uc_unpack
  mlxsw: spectrum: Fix ageing time value
  mlxsw: spectrum: Make mlxsw_sp_port_switchdev_ops static

Or Gerlitz (2):
  mlxsw: Put constant on the right side of comparisons
  mlxsw: Put braces on all arms of branch statement

 Documentation/networking/switchdev.txt             |   7 +-
 drivers/net/ethernet/mellanox/mlxsw/core.c         |   4 +-
 drivers/net/ethernet/mellanox/mlxsw/pci.c          |   3 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  18 +--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   5 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   7 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 144 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c     |   2 +-
 net/switchdev/switchdev.c                          |   5 +-
 9 files changed, 122 insertions(+), 73 deletions(-)

-- 
1.9.3
