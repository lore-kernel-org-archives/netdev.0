From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: Couple of fixes
Date: Fri,  4 Aug 2017 14:12:28 +0200
Message-ID: <20170804121230.2144-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36179 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752547AbdHDMMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:12:34 -0400
Received: by mail-wr0-f196.google.com with SMTP id y67so2877786wrb.3
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:12:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The first patch prevents us from warning about valid situations that can
happen due to the fact that some operations in switchdev are deferred.

Second patch fixes a long standing problem in which we didn't correctly
free resources upon module removal, resulting in a memory leak.

Ido Schimmel (2):
  mlxsw: spectrum_switchdev: Don't warn about valid situations
  mlxsw: spectrum_switchdev: Release multicast groups during fini

 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 37 ++++++++++++++--------
 1 file changed, 24 insertions(+), 13 deletions(-)

-- 
2.9.3
