From: Sebastian Frias <sf84@laposte.net>
Subject: [PATCH v2 0/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 19:17:46 +0100
Message-ID: <581CD0CA.9070506@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>,
        Andrew Lunn <andrew@lunn.ch>
To: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz298.laposte.net ([178.22.154.198]:58553 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S938605AbcKDSRu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 14:17:50 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout010 (Postfix) with ESMTP id 40AF345B702
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:17:47 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout010 (Postfix) with ESMTP id 300A145CC7D
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:17:47 +0100 (CET)
Received: from lpn-prd-vrin002 (lpn-prd-vrin002.prosodie [10.128.63.3])
        by lpn-prd-vrout010 (Postfix) with ESMTP id 28C1145B702
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:17:47 +0100 (CET)
Received: from lpn-prd-vrin002 (localhost [127.0.0.1])
        by lpn-prd-vrin002 (Postfix) with ESMTP id 150385BF1E5
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 19:17:47 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 of the series, only the second patch:
"net: ethernet: nb8800: handle all RGMII definitions" is modified
to account for Florian's suggestion.

Sebastian Frias (2):
  net: ethernet: nb8800: Do not apply TX delay at MAC level
  net: ethernet: nb8800: handle all RGMII definitions

 drivers/net/ethernet/aurora/nb8800.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

-- 
1.7.11.2
