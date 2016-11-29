From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 net-next 0/4] tc: flower: SCTP and other port fixes
Date: Tue, 29 Nov 2016 16:51:29 +0100
Message-ID: <1480434693-29397-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f181.google.com ([209.85.210.181]:33713 "EHLO
        mail-wj0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934039AbcK2PwI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:52:08 -0500
Received: by mail-wj0-f181.google.com with SMTP id xy5so149045713wjc.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:52:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series:

* Makes some improvements to the documentation of flower;
  A follow-up to recent work by Paul Blakey and myself.
* Corrects some errors introduced when SCTP port matching support was
  recently added.

It applies on top of the following:
* [PATCH iproute2] tc: flower: Fix usage message
* [PATCH iproute2 0/2] tc: flower: Support matching on SCTP port

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
