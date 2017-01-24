From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 0/2] vxlan: misc fdb fixes
Date: Mon, 23 Jan 2017 20:44:31 -0800
Message-ID: <1485233073-11391-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:32861 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750704AbdAXEoo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 23:44:44 -0500
Received: by mail-pf0-f178.google.com with SMTP id y143so46913769pfb.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 20:44:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Balakrishnan Raman (1):
  vxlan: do not age static remote mac entries

Roopa Prabhu (1):
  vxlan: don't flush static fdb entries on admin down

 drivers/net/vxlan.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

-- 
v1 -> v2: use bool as suggested by DavidM
