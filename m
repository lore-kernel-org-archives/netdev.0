From: Ben Greear <greearb@candelatech.com>
Subject: ath5k irq warning message
Date: Wed, 22 Apr 2009 14:56:06 -0700
Message-ID: <49EF9276.1060109@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47179 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbZDVV4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 17:56:08 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n3MLu6xd019487
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 22 Apr 2009 14:56:06 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on debugging some sort of live-lock related to irqs
in ath5k with lots of virtual stations.

I notice this code in the ath5k_intr method.

Won't counter be -1 if you break out of this due to the 'counter-- > 0'
clause?

If so, then that warning won't be printed regardless...

	} while (ath5k_hw_is_intr_pending(ah) && counter-- > 0);

	if (unlikely(!counter))
		ATH5K_WARN(sc, "too many interrupts, giving up for now\n");


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

