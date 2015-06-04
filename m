From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] openvswitch: include actions with upcall if
 allocation allows
Date: Thu, 04 Jun 2015 01:13:53 -0700 (PDT)
Message-ID: <20150604.011353.1589451290206511811.davem@davemloft.net>
References: <1433370667-30625-1-git-send-email-neil.mckee@inmon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neil.mckee@inmon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45003 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330AbbFDINy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:13:54 -0400
In-Reply-To: <1433370667-30625-1-git-send-email-neil.mckee@inmon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil McKee <neil.mckee@inmon.com>
Date: Wed,  3 Jun 2015 15:31:07 -0700

> Back out the OVS_USERSPACE_ATTR_ACTIONS attribute that was
> gating the inclusion of datapath actions in the upcall.
> Instead include the actions every time, provided there is no
> problem with the atomic allocation.  If the atomic allocation
> fails then try it again with the actions omitted.
> 
> Signed-off-by: Neil McKee <neil.mckee@inmon.com>

Conditionally providing the attributes to the user is completely
terrible semantics.

If the user really needs these, then he won't be happy to get the
upcall without them, he'd rather the upcall fail completely
instead.

I'm not applying this patch, this change was not well thought out
at all.
