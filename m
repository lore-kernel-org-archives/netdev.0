From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix arp_validate on bonds inside a bridge
Date: Mon, 03 May 2010 16:02:59 -0700
Message-ID: <10955.1272927779@death.nxdomain.ibm.com>
References: <20100429163921.GA4228@midget.suse.cz> <26811.1272567443@death.nxdomain.ibm.com> <20100430154529.GB15803@midget.suse.cz> <20100503.155820.158442623.davem@davemloft.net>
Cc: jbohac@suse.cz, bonding-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:50383 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755514Ab0ECXDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 19:03:13 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43MutF7006040
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 16:56:55 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o43N32U2119836
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 17:03:07 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43N31GT011041
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 17:03:02 -0600
In-reply-to: <20100503.155820.158442623.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Jiri Bohac <jbohac@suse.cz>
>Date: Fri, 30 Apr 2010 17:45:29 +0200
>
>> On Thu, Apr 29, 2010 at 11:57:23AM -0700, Jay Vosburgh wrote:
>>> 	This doesn't apply to the current net-next-2.6 (because
>>> skb_bond_should_drop was pulled out of line a few weeks ago); can you
>>> update the patch?
>> 
>> sure, here it goes:
>
>Jay can I get an ACK or similar?

	Setting up to test it right now; will report back.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
