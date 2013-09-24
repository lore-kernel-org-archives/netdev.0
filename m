From: Ben Greear <greearb@candelatech.com>
Subject: Cannot re-enable 'auto' for IPv6 link local?
Date: Tue, 24 Sep 2013 15:54:18 -0700
Message-ID: <5242181A.6090300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33927 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753899Ab3IXWyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 18:54:19 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r8OMsIpV017740
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 15:54:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At one time, I'm fairly certain this worked, but not having much
luck in a hacked 3.9.11+ kernel:

The goal is to enable the link-local address to be auto-configured.
At start of this, there is no /proc/sys/net/ipv6/config/eth30 dir
because all IPv6 addrs were removed (I suppose).

# ./local/sbin/ip -6 addr add 2345::18 dev eth30
# echo 1 > /proc/sys/net/ipv6/conf/eth30/autoconf
# cat /proc/sys/net/ipv6/conf/eth30/autoconf
1
# ./local/sbin/ip -6 addr del 2345::18 dev eth30
# cat /proc/sys/net/ipv6/conf/eth30/autoconf
cat: /proc/sys/net/ipv6/conf/eth30/autoconf: No such file or directory


What is the proper way to turn on ipv6 auto configuration?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
