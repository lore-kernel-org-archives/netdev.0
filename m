From: Ben Greear <greearb@candelatech.com>
Subject: pre-fetching skb for delayed send
Date: Fri, 06 Jul 2012 16:10:40 -0700
Message-ID: <4FF77070.7040705@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:38513 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756185Ab2GFXKl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 19:10:41 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q66NAecG012370
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 6 Jul 2012 16:10:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose one has a bridge-like thing that may store up packets
for a bit (100+ms) before sending them....

We notice that performance is very good if we can run with (near) zero
delay, but at higher delay, performance goes down significantly when attempting 10G
speeds.  I assume this is because we are sending skbs that are no longer in the cache...

So, is there an easy way to pre-fetch an skb and it's related pages?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
