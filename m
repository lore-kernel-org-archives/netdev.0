From: Ben Greear <greearb@candelatech.com>
Subject: Can we replace the msleep(250) in dev.c  netdev_wait_allrefs?
Date: Tue, 29 Jan 2013 12:00:36 -0800
Message-ID: <51082A64.2090702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39192 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753422Ab3A2UAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:00:38 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0TK0a1o015171
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 12:00:36 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think there was a proposal to change it to schedule_timeout_uninterruptible(1);
some time ago, but that change never made it upstream (at least not in 3.7.5)?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
