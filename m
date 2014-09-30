From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 0/2] netxen: Bug fixes.
Date: Tue, 30 Sep 2014 03:56:34 -0400
Message-ID: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <umgwanakikbuti@gmail.com>,
	<Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:6830 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751356AbaI3Iat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 04:30:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This series fixes some TX specific issues.
* Move spin_lock(tx_clean_lock) in down path to fix
  atomic sleep bug (Reported by Mike Galbraith).
* Fix hang in interface down while running traffic.

Please consider applying this to 'net'.

Thanks,
Manish

Manish Chopra (2):
  netxen: Fix BUG "sleeping function called from invalid context"
  netxen: Fix bug in Tx completion path

 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    6 ++++--
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 --
 2 files changed, 4 insertions(+), 4 deletions(-)
