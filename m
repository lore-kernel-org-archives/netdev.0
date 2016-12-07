From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 iproute2/net-next 0/3] tc: flower: Support matching on ICMP
Date: Wed,  7 Dec 2016 14:54:00 +0100
Message-ID: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:38448 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752335AbcLGNzr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:55:47 -0500
Received: by mail-wm0-f42.google.com with SMTP id f82so168254284wmf.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 05:54:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for matching on ICMP type and code to flower. This is modeled
on existing support for matching on L4 ports.

The second patch provided a minor cleanup which is in keeping with
they style used in the last patch.

This is marked as an RFC to match the same designation given to the
corresponding kernel patches.


Changes since v1:
* Rebase
* Do not run noths() on u8 entity

Simon Horman (3):
  tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
  tc: flower: introduce enum flower_endpoint
  tc: flower: support matching on ICMP type and code

 include/linux/pkt_cls.h |  10 ++++
 man/man8/tc-flower.8    |  20 ++++++--
 tc/f_flower.c           | 123 +++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 135 insertions(+), 18 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
