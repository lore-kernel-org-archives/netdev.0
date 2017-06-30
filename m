From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: small MCDI cleanups
Date: Fri, 30 Jun 2017 15:52:58 +0100
Message-ID: <fd53588b-c163-4c82-a8f2-c0b08ccb95b5@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dispatch1-us1.ppe-hosted.com ([67.231.154.164]:33819 "EHLO
        dispatch1-us1.ppe-hosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751751AbdF3OxL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2017 10:53:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giving the full MCDI event rather than just the code can aid in
 debugging.  While fixing this I noticed an outdated comment.

Edward Cree (1):
  sfc: correct comment on efx_mcdi_process_event

Jon Cooper (1):
  sfc: change Unknown MCDI event message to print full event.

 drivers/net/ethernet/sfc/mcdi.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)
