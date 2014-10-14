From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 0/2] qlcnic: Bug fixes
Date: Tue, 14 Oct 2014 07:41:44 -0400
Message-ID: <1413286906-14220-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:21200 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932144AbaJNMQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 08:16:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes following issues.

* We were programming maximum number of arguments supported by
  adapter instead of required in a command.
* Destroy tx command requires three arguments instead of two.

Please apply these patches to net.

Thanks,
Rajesh

Rajesh Borundia (2):
  qlcnic: Fix programming number of arguments in a command.
  qlcnic: Fix number of arguments in destroy tx context command

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)
