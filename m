From: Simon Horman <simon.horman@netronome.com>
Subject: [[PATCH iproute2/net-next v2] 0/4] tc: flower: SCTP and other port fixes
Date: Fri,  2 Dec 2016 09:45:17 +0100
Message-ID: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:33520 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758481AbcLBIpg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:45:36 -0500
Received: by mail-wm0-f43.google.com with SMTP id c184so2317567wmd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 00:45:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

this short series:

* Makes some improvements to the documentation of flower;
  A follow-up to recent work by Paul Blakey and myself.
* Corrects some errors introduced when SCTP port matching support was
  recently added.

Changes since v2:
* Rebase

Simon Horman (4):
  tc: flower: remove references to eth_type in manpage
  tc: flower: document SCTP ip_proto
  tc: flower: correct name of ip_proto parameter to flower_parse_port()
  tc: flower: make use of flower_port_attr_type() safe and silent

 man/man8/tc-flower.8 | 37 ++++++++++++++++++-------------------
 tc/f_flower.c        | 32 +++++++++++++++++---------------
 2 files changed, 35 insertions(+), 34 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
