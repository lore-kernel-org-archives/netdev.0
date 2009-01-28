From: Ben Greear <greearb@candelatech.com>
Subject: Question on netif_tx_queue_stopped
Date: Tue, 27 Jan 2009 22:05:01 -0800
Message-ID: <497FF58D.50601@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57474 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751878AbZA1GFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 01:05:04 -0500
Received: from [71.112.51.220] (pool-71-112-51-220.sttlwa.dsl-w.verizon.net [71.112.51.220])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n0S652hP007431
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 22:05:02 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm doing some tests with pktgen and the 8139too (realtek) driver
in kernel 2.6.29-rc2.

It seems that netif_tx_queue_stopped will return false fairly often even 
if the
cable is pulled from the NIC.

Is that expected?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


