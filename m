From: Ben Greear <greearb@candelatech.com>
Subject: Is skb->queue_mapping valid for received packets?
Date: Mon, 13 Jun 2011 18:59:45 -0700
Message-ID: <4DF6C091.5050301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40988 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab1FNB7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 21:59:46 -0400
Received: from [50.47.228.156] (50-47-228-156.evrt.wa.frontiernet.net [50.47.228.156])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p5E1xjCD020444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 13 Jun 2011 18:59:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Anyone know if skb->queue_mapping is set for incoming packets, ie to
notify which queue they came in on?  I can't find it set anywhere,
and it appears it is sometimes set to 1 when it should be 0 in
my system.

Maybe it's never actually set, and I'm just reading some stale
data?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
