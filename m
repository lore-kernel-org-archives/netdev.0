From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 0/2] bonding: couple of bug fixes
Date: Tue, 11 Jun 2013 09:42:14 -0700
Message-ID: <30610.1370968934@death.nxdomain>
References: <1370519702-18581-1-git-send-email-nikolay@redhat.com> <20130611.024530.1458814488844049119.davem@davemloft.net>
Cc: nikolay@redhat.com, netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:33791 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab3FKQnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 12:43:39 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 11 Jun 2013 10:43:38 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id AF3D43E40030
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 10:43:17 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5BGhRlb041306
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 10:43:27 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5BGgGxs016184
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 10:42:17 -0600
In-reply-to: <20130611.024530.1458814488844049119.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: nikolay@redhat.com
>Date: Thu,  6 Jun 2013 13:55:00 +0200
>
>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>> 
>> Hello,
>> Patch 01 resets the master's mac if the first enslave fails and the slave's
>> mac was set to the master's prior.
>> Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
>> param and was silently not working if the value was >127) so it can go up to 255
>> (as per documentation). It also fixes two tricky race conditions which were
>> hidden because of the previous bug.
>
>There was some minor back and forth between Jay and Nikolay on this set,
>but I'd like to see some ACKs before applying this stuff.

	I'm fine with the code changes, although I think a description
of the three way race that Nikolay described in his last email should be
in the log message, perhaps along with a brief description of what
conditions would trigger the problem.

	With the above caveat:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
