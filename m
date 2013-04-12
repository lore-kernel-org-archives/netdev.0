From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] vxlan: revert "vxlan: Bypass encapsulation if
 the destination is local"
Date: Fri, 12 Apr 2013 19:17:53 -0400 (EDT)
Message-ID: <20130412.191753.1552187310594391418.davem@davemloft.net>
References: <1365724799.3563.5.camel@sridhar.usor.ibm.com>
	<20130412.151916.63924835658790088.davem@davemloft.net>
	<516893BD.20303@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752577Ab3DLXR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 19:17:56 -0400
In-Reply-To: <516893BD.20303@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 12 Apr 2013 16:07:41 -0700

> Is it a bug that RTCF_LOCAL is set here when veth0's peer is moved
> to a different netns?

Nope.

RTCF_LOCAL is set in several situations.

For example, it would be set on a broadcast route for a subnet we are
on.  It'd also be set on a multicast route for a multicast group the
local system is subscribed to.
