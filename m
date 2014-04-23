From: David Miller <davem@davemloft.net>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 21:16:42 -0400 (EDT)
Message-ID: <20140422.211642.1908374698598409144.davem@davemloft.net>
References: <20140423092606.c73425b64d127b8f94469fcb@redhat.com>
	<20140422170438.00006b45@unknown>
	<20140423111203.3e8cf3a9a12acb1d95b3635a@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, ben@decadent.org.uk,
	netdev@vger.kernel.org, benve@cisco.com, ssujith@cisco.com,
	govindarajulu90@gmail.com, neepatel@cisco.com, nistrive@cisco.com
To: dgibson@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44834 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705AbaDWBQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:16:45 -0400
In-Reply-To: <20140423111203.3e8cf3a9a12acb1d95b3635a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Gibson <dgibson@redhat.com>
Date: Wed, 23 Apr 2014 11:12:03 +1000

> And therein lies the problem.  I don't even know what the IFLA_VF_PORTS
> info is for, but presumably something uses it.  If they stop receiving
> it, they can be expected to break horribly.

We did the same thing to VFINFO list.

All the users I could find already set the mask unconditionally
for all device dumps.

It's absolutely, positively, the only reasonable fix for this
problem.
