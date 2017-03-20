From: Heiner Kallweit <hkallweit1@gmail.com>
Subject: linux-next-20170320 breaks stmmac on meson (Amlogic S905GXBB)
Date: Mon, 20 Mar 2017 22:58:06 +0100
Message-ID: <690d5153-7725-83e6-208a-6cb4cac3cd93@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: clabbe.montjoie@gmail.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joao Pinto <jpinto@synopsys.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33805 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751467AbdCTV6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 17:58:20 -0400
Received: by mail-wr0-f193.google.com with SMTP id u48so20129823wrc.1
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 14:58:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As reported by Corentin Labbe before:
stmmac in the latest next kernel is broken also on meson8b.

The following commit seems to create the trouble:
6deee2221e11 "net: stmmac: prepare dma op mode config for multiple queues"

I also get queue timeout errors.

Rgds, Heiner
