From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 35862] New: arp requests from wrong src IP
Date: Wed, 25 May 2011 21:52:22 -0400 (EDT)
Message-ID: <20110525.215222.22117057747103565.davem@davemloft.net>
References: <bug-35862-10286@https.bugzilla.kernel.org/>
	<20110525163137.6f04f26e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, matare@lih.rwth-aachen.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756118Ab1EZBw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 21:52:58 -0400
In-Reply-To: <20110525163137.6f04f26e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 25 May 2011 16:31:37 -0700

>> I switched a host's ip address from 137.226.164.13 to 137.226.164.2. The .13 IP
>> now belongs to the host that had .2 before (I swapped them). Now both hosts
>> still arp from their old IPs although ifconfig as well as ip clearly tell
>> otherwise. Examining the host which now has 137.226.164.13:
>> 
>> # ip addr show dev eth0
>> 4: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
>>     link/ether 00:e0:81:41:1f:e4 brd ff:ff:ff:ff:ff:ff
>>     inet 137.226.164.2/24 brd 137.226.164.255 scope global eth0
>>     inet 192.168.23.2/24 brd 137.226.164.255 scope global eth0:0

If you keep the old IP address around it remains as the "primary"
IP address.

You have to explicitly remove the original IP address from the
interface first, then add the new one, in order for the new
one to become the "primary"

Not a bug, please close this.
