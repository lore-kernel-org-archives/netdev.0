From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] mlxsw: spectrum_router: Increase VRF scale
Date: Mon, 14 Aug 2017 10:54:02 +0200
Message-ID: <20170814085405.1452-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36579 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752381AbdHNIyI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 04:54:08 -0400
Received: by mail-wr0-f195.google.com with SMTP id y67so6581932wrb.3
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 01:54:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The purpose of this set is to increase the maximum number of supported VRF
devices on top of the Spectrum ASIC under different workloads.

This is achieved by sharing the same LPM tree across all the virtual
routers for a given L3 protocol (IPv4 / IPv6). The change is explained in
detail in the third patch. First two patches are small changes to make
review easier.

Ido Schimmel (3):
  mlxsw: spectrum_router: Return void from deletion functions
  mlxsw: spectrum_router: Pass argument explicitly
  mlxsw: spectrum_router: Use one LPM tree for all virtual routers

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 282 +++++++++++++--------
 1 file changed, 176 insertions(+), 106 deletions(-)

-- 
2.9.3
