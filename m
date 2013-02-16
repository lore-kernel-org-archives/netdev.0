From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next (V2)] ipv6: Queue fragments per interface
 for multicast/link-local addresses.
Date: Sat, 16 Feb 2013 20:39:29 +0900
Message-ID: <511F6FF1.9000004@linux-ipv6.org>
References: <511F1E03.9010205@linux-ipv6.org> <1360995918.19353.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Ben Greear <greearb@candelatech.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:39824 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753066Ab3BPLja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2013 06:39:30 -0500
In-Reply-To: <1360995918.19353.56.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> On Sat, 2013-02-16 at 14:49 +0900, YOSHIFUJI Hideaki wrote:
>> We should queue fragments for the same link-local address on
>> different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
>> different queue, because of nature of addressing architecture.
>>
>> Similarly, we should queue fragments for multicast on different
>> interface to the different queue.  This is okay because
>> application joins group on speicific interface, and multicast
>> traffic is expected only on that interface.
>>
>> CC: Ben Greear <greearb@candelatech.com>
>> CC: Vlad Yasevich <vyasevic@redhat.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> ---
> 
> I would definitely ask advice from Patrick & Pablo on this patch.
> 
> If a router uses several links in aggregation (but no bonding dev), we
> might break fragmentation/reassembly.

Could you elaborate, please?

The patch does not compare incoming interface if address is
non-link-local unicast address.

--yoshfuji
