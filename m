From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 0/2] bnx2x: kdump related fixes
Date: Wed, 1 Apr 2015 10:02:18 +0300
Message-ID: <1427871740-26271-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:13417 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097AbbDAHCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 03:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series aims to fix bnx2x driver issues when loading in kdump kernel.
Both issues fixed here would be fatal to the device, requiring full reset of
the system in order to recover, preventing the device from serving its purpose
in the kdump environment.

Dave,

Please consider applying this series to `net'.

Thanks,
Yuval
-- 
1.8.3.1
