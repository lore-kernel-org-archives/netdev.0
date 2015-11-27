From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/6] mlxsw: driver update
Date: Fri, 27 Nov 2015 13:45:53 +0100
Message-ID: <1448628359-20077-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35716 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbK0MqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 07:46:05 -0500
Received: by wmuu63 with SMTP id u63so54382967wmu.0
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 04:46:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset carries support for port identification, monitoring
of ASIC temperature and board fans.

Ido Schimmel (2):
  mlxsw: reg: Add Management LED Control register definition
  mlxsw: spectrum: Add support for port identification

Jiri Pirko (4):
  mlxsw: reg: Add definition of temperature management registers
  mlxsw: core: Implement temperature hwmon interface
  mlxsw: reg: Add definition of fan management registers
  mlxsw: core: Implement fan control using hwmon

 drivers/net/ethernet/mellanox/mlxsw/Kconfig      |   8 +
 drivers/net/ethernet/mellanox/mlxsw/Makefile     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/core.c       |   8 +
 drivers/net/ethernet/mellanox/mlxsw/core.h       |  24 ++
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 342 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/reg.h        | 290 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c   |  24 ++
 7 files changed, 697 insertions(+)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c

-- 
1.9.3
