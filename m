From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next 0/2] bonding: extend round-robin mode
Date: Wed, 06 Nov 2013 08:55:49 -0800
Message-ID: <23278.1383756949@death.nxdomain>
References: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	vfalico@redhat.com
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:37104 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab3KFQz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 11:55:58 -0500
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 6 Nov 2013 09:55:57 -0700
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8FB3138C8027
	for <netdev@vger.kernel.org>; Wed,  6 Nov 2013 11:55:51 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rA6GtqC71835512
	for <netdev@vger.kernel.org>; Wed, 6 Nov 2013 16:55:52 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rA6GtpCB018927
	for <netdev@vger.kernel.org>; Wed, 6 Nov 2013 11:55:52 -0500
In-reply-to: <1383655902-18744-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nikolay Aleksandrov <nikolay@redhat.com> wrote:

>This small patchset adds a new option called packets_per_slave to the
>bonding which aims to extend round-robin mode with the following effects:
>0 - choose the slave id at random
>1 - packet per slave (standard round-robin, default option value)
> >1 - transmit >1 packets per slave, switch the slaves in round-robin
>Patch02 adds a description for the new option to the bonding documentation.

	Could you explain why this is useful?  My guess is that you're
trying to synchronize with the packet receive processing of a peer
(perhaps for GRO?), but I think it would be useful to explain the
utility of this.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
