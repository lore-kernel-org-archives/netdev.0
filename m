From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 0/7] tc: flower: Masked ICMP match and ND match
Date: Thu,  2 Feb 2017 11:38:33 +0100
Message-ID: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35050 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdBBKix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:38:53 -0500
Received: by mail-wm0-f52.google.com with SMTP id b65so83828187wmf.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:38:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this series have several related parts.

* tc: flower: Update documentation to indicate ARP takes IPv4 prefixes

  Enhance documentation for consistency with later documentation changes.

* tc: flower: use correct type when calling flower_icmp_attr_type

  Type correction to ICMP code; should not have runtime effect

* tc: flower: provide generic masked u8 parser helper
  tc: flower: provide generic masked u8 print helper

  Generic parsing and printing of masked u8 options

* tc: flower: support masked ICMP code and type match

  Support masking ICMP code and type matches.
  Unmasked matching is already supported by iproute2
  Masked matching is already supported by the kernel.

  This is used by the ND patches

* tc: flower: Add TCA_FLOWER_KEY_ND_*
  tc: flower: Support matching on ND

The last two patches are marked as RFC as they support functionality
submitted to but not yet not yet present in the kernel.


Simon Horman (7):
  tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
  tc: flower: use correct type when calling flower_icmp_attr_type
  tc: flower: provide generic masked u8 parser helper
  tc: flower: provide generic masked u8 print helper
  tc: flower: support masked ICMP code and type match
  tc: flower: Add TCA_FLOWER_KEY_ND_*
  tc: flower: Support matching on ND

 include/linux/pkt_cls.h |   7 ++
 man/man8/tc-flower.8    |  58 +++++++++--
 tc/f_flower.c           | 260 +++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 258 insertions(+), 67 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
