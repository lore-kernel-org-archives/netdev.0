From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/1] qlcnic: add wmb() call in transmit data path.
Date: Wed, 29 Jun 2016 17:51:33 -0400
Message-ID: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:3478 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751038AbcF2XdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 19:33:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

0001-qlcnic-add-wmb-call-in-transmit-data-path.patch

This patch adds a wmb() call in the Tx data path to ensure
writes are completed before hardware fetches updated Tx descriptors.

Please apply to net.

Thanks,
Sony
