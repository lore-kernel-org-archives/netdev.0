From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next v3 0/3] tc: flower: SCTP and other port fixes
Date: Sat,  3 Dec 2016 09:52:37 +0100
Message-ID: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36186 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751455AbcLCIxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 03:53:00 -0500
Received: by mail-wm0-f53.google.com with SMTP id g23so37307348wme.1
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 00:52:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

this short series:

* Makes some improvements to the documentation of flower;
  A follow-up to recent work by Paul Blakey and myself.
* Corrects some errors introduced when SCTP port matching support was
  recently added.

Changes v2->v3:
* Rebase
* Dropped merged patch

Changes v1->v2:
* Rebase

Simon Horman (3):
  tc: flower: document SCTP ip_proto
  tc: flower: correct name of ip_proto parameter to flower_parse_port()
  tc: flower: make use of flower_port_attr_type() safe and silent

 man/man8/tc-flower.8 | 14 +++++++-------
 tc/f_flower.c        | 32 +++++++++++++++++---------------
 2 files changed, 24 insertions(+), 22 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
