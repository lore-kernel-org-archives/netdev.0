From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH v2 0/2] bonding: couple of bug fixes
Date: Tue, 11 Jun 2013 15:14:04 -0700
Message-ID: <2290.1370988844@death.nxdomain>
References: <1370988422-2035-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:55817 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756433Ab3FKWOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 18:14:11 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Tue, 11 Jun 2013 16:14:11 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7BF9E6E8057
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 18:14:02 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5BME6U7309826
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 18:14:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5BME5R6020099
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 18:14:06 -0400
In-reply-to: <1370988422-2035-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nikolay@redhat.com wrote:

>From: Nikolay Aleksandrov <nikolay@redhat.com>
>
>Hello,
>Patch 01 resets the master's mac if the first enslave fails and the slave's
>mac was set to the master's prior.
>Patch 02 fixes a type bug of igmp_retrans (which is the counter of igmp_resend
>param and was silently not working if the value was >127) so it can go up to 255
>(as per documentation). It also fixes two tricky race conditions which were
>hidden because of the previous bug.
>
>V2: Updated patch 02 commit message as per Jay's comment

	For both patches:

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
