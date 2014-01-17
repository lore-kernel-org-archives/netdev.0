From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 0/2] Bug Fixes for SFC driver
Date: Fri, 17 Jan 2014 19:45:36 +0000
Message-ID: <52D98860.4020402@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38168 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592AbaAQTpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 14:45:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am taking over the upstream patch submission work for the 
sfc driver from Ben Hutchings.

These patches are bug fixes to the sfc driver involving 
replacement of the PORT RESET MC command and fixing transposed 
ptp_{under,over}size_sync_window_statistics

The PORT_RESET bug fix is needed for all versions supporting EF10
i.e all versions including and after 3.12.

Ben Hutchings (1):
  sfc: Fix transposed ptp_{under,over}size_sync_windows statistics

Jon Cooper (1):
  sfc: Change efx_mcdi_reset_port to use ENTITY_RESET MC command.

 drivers/net/ethernet/sfc/ef10.c |   31 ++++++++++++++++++++++++++-----
 drivers/net/ethernet/sfc/mcdi.c |   14 +++++++++++---
 drivers/net/ethernet/sfc/ptp.c  |    4 ++--
 3 files changed, 39 insertions(+), 10 deletions(-)
