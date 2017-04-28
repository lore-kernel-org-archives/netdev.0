From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 0/3] tc: flower: allow control of tree traversal on packet parse errors
Date: Fri, 28 Apr 2017 14:02:58 +0200
Message-ID: <20170428120301.16500-1-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:37252 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425804AbdD1MDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:03:16 -0400
Received: by mail-wm0-f43.google.com with SMTP id m123so44655665wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:03:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series is intended to allow control how the tree of qdisc, classes and
filters is further traversed if an error is encountered when parsing the
packet in order to match the cls_flower filters at a particular prio.

Please see the changelog of the last patch of this series for a more
detailed description.


Simon Horman (3):
  tc: flower: update headers for TCA_FLOWER_KEY_MPLS*
  tc: flower: update headers for TCA_FLOWER_HEADER_PARSE_ERR_ACT
  tc: flower: allow control of tree traversal on packet parse errors

 include/linux/pkt_cls.h |  7 +++++++
 man/man8/tc-flower.8    | 29 +++++++++++++++++++++++++++--
 tc/f_flower.c           | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 67 insertions(+), 2 deletions(-)

-- 
2.12.2.816.g2cccc81164
