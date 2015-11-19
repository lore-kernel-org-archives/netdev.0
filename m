From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: small driver update
Date: Thu, 19 Nov 2015 12:27:37 +0100
Message-ID: <1447932460-4615-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:33020 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932116AbbKSL1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 06:27:43 -0500
Received: by wmec201 with SMTP id c201so20614345wme.0
        for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 03:27:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Couple of VLAN-related patches.

Ido Schimmel (3):
  mlxsw: spectrum: Use correct PVID value when removing VLANs
  mlxsw: spectrum: Unify setting of HW VLAN filters
  mlxsw: spectrum: Add error paths to __mlxsw_sp_port_vlans_add

 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 129 ++++++++++++++-------
 1 file changed, 84 insertions(+), 45 deletions(-)

-- 
1.9.3
