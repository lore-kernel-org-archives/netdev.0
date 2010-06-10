From: Ben Greear <greearb@candelatech.com>
Subject: Interesting issue when using IPv6 autoconf sysctl.
Date: Wed, 09 Jun 2010 18:09:35 -0700
Message-ID: <4C103B4F.2050604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35733 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755984Ab0FJBJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 21:09:36 -0400
Received: from [71.117.12.23] (pool-71-117-12-23.sttlwa.dsl-w.verizon.net [71.117.12.23])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o5A19Z7A024606
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 9 Jun 2010 18:09:36 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just tried using the /proc/sys/net/ipv6/conf/[dev]/autoconf
feature to run off auto-configured link-local addresses
for one of my interfaces.

It worked like a charm, the address is gone,
and now the /proc/sys/net/ipv6/conf/[dev]
directory does not exist so I can't turn it back on!

I can work around this by forcing an ipv6 address back
onto the interface and then removing it, but that
is pretty crufty!

There has got to be a better way to implement this!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
