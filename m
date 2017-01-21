From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 0/2] vxlan: misc fdb fixes
Date: Fri, 20 Jan 2017 23:43:17 -0800
Message-ID: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33612 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751268AbdAUHn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Jan 2017 02:43:29 -0500
Received: by mail-pg0-f54.google.com with SMTP id 204so29897524pge.0
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 23:43:29 -0800 (PST)
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
1.9.1
