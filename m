From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] Net-ethtool : Allow ethtool to set interface in
 loopback mode.
Date: Thu, 09 Dec 2010 20:11:42 -0800 (PST)
Message-ID: <20101209.201142.71115585.davem@davemloft.net>
References: <1291215255.3170.12.camel@bwh-desktop>
	<AANLkTikW24AcLEAioYtCwuQOoVnTrqVoAaZw3sksZ_jU@mail.gmail.com>
	<1291234623.3170.17.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, netdev@vger.kernel.org, chavey@google.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754838Ab0LJELO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 23:11:14 -0500
In-Reply-To: <1291234623.3170.17.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 01 Dec 2010 20:17:03 +0000

> On Wed, 2010-12-01 at 12:14 -0800, Mahesh Bandewar wrote:
>> This patch enables ethtool to set the loopback mode on a given
>> interface. By configuring the interface in loopback mode in conjunction
>> with a policy route / rule, a userland application can stress the egress /
>> ingress path exposing the flows of the change in progress and potentially
>> help developer(s) understand the impact of those changes without even
>> sending a packet out on the network.
>> 
>> Following set of commands illustrates one such example -
>>    a) ip -4 addr add 192.168.1.1/24 dev eth1
>>    b) ip -4 rule add from all iif eth1 lookup 250
>>    c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
>>    d) arp -Ds 192.168.1.100 eth1
>>    e) arp -Ds 192.168.1.200 eth1
>>    f) sysctl -w net.ipv4.ip_nonlocal_bind=1
>>    g) sysctl -w net.ipv4.conf.all.accept_local=1
>>    # Assuming that the machine has 8 cores
>>    h) taskset 000f netserver -L 192.168.1.200
>>    i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30
>> 
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> [...]
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

This patch doesn't apply, it has been corrupted by Mahesh's email
client.

Mahesh, please correct this problem and resubmit.
