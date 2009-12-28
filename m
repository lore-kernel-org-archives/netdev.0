From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6 v4] bonding: allow arp_ip_targets on separate vlans to use arp validation
Date: Mon, 28 Dec 2009 13:55:33 -0800
Message-ID: <13580.1262037333@death.nxdomain.ibm.com>
References: <20091214204858.GP1639@gospo.rdu.redhat.com> <20091225.182230.183058983.davem@davemloft.net> <20091228152632.GA6490@gospo.rdu.redhat.com> <20091228.073308.112591206.davem@davemloft.net>
Cc: andy@greyhouse.net, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:50371 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbZL1Vzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 16:55:52 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBSLn0ca013101
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 14:49:00 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBSLtn4Y173942
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 14:55:49 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBSLvjeA000628
	for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 14:57:46 -0700
In-reply-to: <20091228.073308.112591206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Andy Gospodarek <andy@greyhouse.net>
>Date: Mon, 28 Dec 2009 10:26:32 -0500
>
>> This patch should be ready for inclusion.
>
>Yes, but I haven't seen ACK's from Jay or Eric.

	I was testing with the final patch just before my personal
holiday adventures began, and was having one problem: the ARP monitor
part worked fine on the VLAN (the slaves were up) but regular traffic on
that same VLAN, e.g., ping, was dropped on receive at the bond.  The
peer (without bonding) saw the traffic, and responded, but it appeared
that ARP replies from the peer (again, over the VLAN) weren't making it
to the ARP table (at the bond end), so everything that depended on the
ARP table wasn't working.

	I'm willing to believe this is a personal problem at my end, but
I haven't determined the cause, and won't have the opportunity until
next week (after my house has drained of relatives).

	If Andy isn't seeing the above misbehavior, I'm fine with
assuming it's my problem and applying the patch; if I find something
actually wrong with the patch next week we can address it then.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
