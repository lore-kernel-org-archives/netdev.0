From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next v2 0/2] tc: flower: allow control of tree traversal on packet parse errors
Date: Fri,  5 May 2017 14:51:23 +0200
Message-ID: <1493988685-7891-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36520 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753514AbdEEMvs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:51:48 -0400
Received: by mail-wm0-f52.google.com with SMTP id u65so22977934wmu.1
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:51:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series is intended to allow control how the tree of qdisc, classes and
filters is further traversed if an error is encountered when parsing the
packet in order to match the cls_flower filters at a particular prio.

Please see the changelog of the last patch of this series for a more
detailed description.

Changes between RFCv1 and RFCv2:
* Rename new attribute in last path TCA_FLOWER_META_TRUNCATED
* Drop patch to add TCA_FLOWER_KEY_MPLS*: it is in net-next now


Simon Horman (2):
  tc: flower: update headers for TCA_FLOWER_META_TRUNCATED
  tc: flower: allow control of tree traversal on packet parse errors

 include/linux/pkt_cls.h |  2 ++
 man/man8/tc-flower.8    | 29 +++++++++++++++++++++++++++--
 tc/f_flower.c           | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 62 insertions(+), 2 deletions(-)
