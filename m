From: Ben Greear <greearb@candelatech.com>
Subject: Why is bridge's sysfs values in 1/100 of second?
Date: Tue, 13 Jan 2015 18:35:06 -0800
Message-ID: <54B5D5DA.5080008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:52215 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbbANCkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:40:09 -0500
Received: from [192.168.100.236] (unknown [50.251.239.81])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id E556740DBDB
	for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 18:35:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are the units supposed to be 1/100 of a second, or is that just some
luck depending on HZ?


root@ath9k-138:/home/lanforge# brctl setageing br0 98
root@ath9k-138:/home/lanforge# cat /sys/class/net/br0/bridge/ageing_time
9800

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
