From: Ben Greear <greearb@candelatech.com>
Subject: Lost in iptables code.
Date: Thu, 22 Jul 2010 11:02:56 -0700
Message-ID: <4C4887D0.3050309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60718 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab0GVSC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 14:02:57 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o6MI2ubE015659
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 22 Jul 2010 11:02:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to debug an appearant bug in the "CT zones"
logic in 2.6.34, and I'm having a hard time figuring out where the
code enters the iptables logic.  (In case it matters, the
CT Zones logic is related to the 'raw' table.)

I assume it would be somewhere in netif_receive_skb,
but I don't see anything obvious.

If anyone has suggestions where to start poking at this,
please let me know.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

