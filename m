From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down interface
Date: Thu, 01 Jul 2010 13:23:21 +0200
Message-ID: <871vbn1m52.fsf@basil.nowhere.org>
References: <OF1D06F11A.44DE8C5A-ONC125773F.00437856-C125773F.004425B9@transmode.se>
	<20100611084854.0680c014@nehalam>
	<OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35170 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab0GALX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 07:23:27 -0400
In-Reply-To: <OF62B30BCC.F8523B86-ONC1257750.00687496-C1257750.0068AA27@transmode.se>
	(Joakim Tjernlund's message of "Mon, 28 Jun 2010 21:03:13 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund <joakim.tjernlund@transmode.se> writes:

> Stephen Hemminger <shemminger@vyatta.com> wrote on 2010/06/11 17:48:54:
>>
>> When Linux is used as a router, it is undesirable for the kernel to process
>> incoming packets when the address assigned to the interface is down.
>> The initial problem report was for a management application that used ICMP
>> to check link availability.
>>
>> The default is disabled to maintain compatibility with previous behavior.
>> This is not recommended for server systems because it makes fail over more
>> difficult, and does not account for configurations where multiple interfaces
>> have the same IP address.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> Ping David et. all?
> I too want this.

Doesn't arpfilter enable this already? If you set in on the still up
interfaces those will not answer to other IP addresses.

This only works on the ARP level, so it has to wait until the arp
cache in the remote host times out.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
