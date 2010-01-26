From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Netlink usage question (for bonding comm with userspace)
Date: Mon, 25 Jan 2010 17:14:00 -0800
Message-ID: <19462.1264468440@death.nxdomain.ibm.com>
References: <15914.1264466901@death.nxdomain.ibm.com> <20100125.165152.132891922.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:34372 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012Ab0AZBOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 20:14:10 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e34.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0Q184ox020041
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 18:08:04 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0Q1E3RL092222
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 18:14:03 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0Q1E2DO028213
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 18:14:02 -0700
In-reply-to: <20100125.165152.132891922.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
[...]
>> 	I could, for this project, use a netlink_kernel_create and
>> socket(AF_NETLINK) pair to perform the communication (presumably adding
>> a NETLINK_BONDING or the like to <linux/netlink.h>).
>
>This is no longer done, so that we don't have an issue with
>running out of netlink sub-protocol numbers.
>
>Instead use generic netlink, the IDs are allocated dynamically
>and looked up via text strings which provides a better scheme
>for namespace allocation.

	Thanks for the response.

	Just so I'm clear, though: use generic netlink for the needs of
this particular project, and then later it's acceptable to have both
generic and rtnetlink co-existing for their respective uses?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
