From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 0/2] net/sched: support tunnel options in cls_flower and act_tunnel_key
Date: Tue, 12 Sep 2017 16:20:35 +0200
Message-ID: <1505226037-2758-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:45544 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751379AbdILOVq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 10:21:46 -0400
Received: by mail-wm0-f45.google.com with SMTP id f199so58551326wme.0
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 07:21:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the flower classifier to match on tunnel options and the
tunnel key action to set them.

Tunnel options are a bytestring of up to 256 bytes.
The flower classifier matching with an optional bitwise mask.
Tunnel implementations may support more or less options,
or none at all.

Simon Horman (2):
  net/sched: add tunnel option support to act_tunnel_key
  net/sched: allow flower to match tunnel options

 include/net/flow_dissector.h              | 13 ++++++++++++
 include/uapi/linux/pkt_cls.h              |  3 +++
 include/uapi/linux/tc_act/tc_tunnel_key.h |  1 +
 net/sched/act_tunnel_key.c                | 26 ++++++++++++++++++-----
 net/sched/cls_flower.c                    | 35 ++++++++++++++++++++++++++++++-
 5 files changed, 72 insertions(+), 6 deletions(-)

-- 
2.1.4
