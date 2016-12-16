From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 0/2] tc: flower: enhance mask support
Date: Fri, 16 Dec 2016 14:54:35 +0100
Message-ID: <1481896477-13497-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35636 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759406AbcLPOBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 09:01:13 -0500
Received: by mail-wm0-f43.google.com with SMTP id a197so34312678wmd.0
        for <netdev@vger.kernel.org>; Fri, 16 Dec 2016 06:01:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this short series enhances mask support for tc flower by:
* Documenting existing mask support for *_ip parameters
* Allowing *_mac options to accept a mask.
  This makes use of existing kernel features.

Based on net-next +
"[PATCH iproute2 0/2] Add dest UDP port to IP tunnel parameters"

Simon Horman (2):
  tc: flower: document that *_ip parameters take a PREFIX as an
    argument.
  tc: flower: Allow *_mac options to accept a mask

 man/man8/tc-flower.8 | 41 +++++++++++++++++++++++------------------
 tc/f_flower.c        | 51 ++++++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 63 insertions(+), 29 deletions(-)

-- 
2.7.0.rc3.207.g0ac5344
