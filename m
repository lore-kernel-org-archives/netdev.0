From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] make flow dissector great again
Date: Mon,  6 Mar 2017 16:39:50 +0100
Message-ID: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33498 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754670AbdCFPj7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:39:59 -0500
Received: by mail-wr0-f196.google.com with SMTP id g10so22212118wrg.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:39:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset follows-up the discussion about future extensions of flow
dissector and tries to address the mentioned concerns. Some parts are
cut out into sub-functions. Also, the processing of the code (ARP, MPLS)
is made dependent on user actually requiring the bisected values.
This prepares the code for future extensions to bisect IPv6 ND messages,
TCP flags, etc.

Jiri Pirko (5):
  flow_dissector: Move ARP dissection into a separate function
  flow_dissector: Move MPLS dissection into a separate function
  flow_dissector: Fix GRE header error path
  flow_dissector: rename "proto again" goto label
  flow_dissector: Move GRE dissection into a separate function

 net/core/flow_dissector.c | 426 ++++++++++++++++++++++++++--------------------
 1 file changed, 238 insertions(+), 188 deletions(-)

-- 
2.7.4
