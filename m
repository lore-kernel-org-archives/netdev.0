From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net 0/3] alx: fix fallout from multi queue conversion
Date: Tue, 24 Jan 2017 14:34:21 +0100
Message-ID: <cover.1485263833.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33886 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdAXNen (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 08:34:43 -0500
Received: by mail-wm0-f65.google.com with SMTP id c85so34626515wmi.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 05:34:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are 3 fixes for the multi queue conversion in v4.10.

The first patch fixes a wrong condition in an if statement.

Patches 2 and 3 fixes regressions in the corner case when requesting msi-x
interrupts fails and we fall back to msi or legacy interrupts.

Tobias Regnery (3):
  alx: fix wrong condition to free descriptor memory
  alx: fix fallback to msi or legacy interrupts
  alx: work around hardware bug in interrupt fallback path

 drivers/net/ethernet/atheros/alx/main.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

-- 
2.9.3
