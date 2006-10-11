From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 7296] New: Connected networks persist in routing table
 despite no IF_RUNNING
Date: Wed, 11 Oct 2006 14:50:25 -0700 (PDT)
Message-ID: <20061011.145025.100208791.davem@davemloft.net>
References: <20061011141213.6b80093c@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24754
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422667AbWJKVuZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 17:50:25 -0400
To: shemminger@osdl.org
In-Reply-To: <20061011141213.6b80093c@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 11 Oct 2006 14:12:13 -0700

> I rejected this because I don't consider "sticky routes" when link is down
> a bug.

This definitely sounds like it is in the realm of userspace policy.
The routing daemon should adjust the routes, as appropriate, if
a link loses it's IF_RUNNING and it wants to use a backup route.

IFF_RUNNING does not cause routes to get flushed, only IFF_UP events
do.

Changing routes based upon IFF_RUNNING state is a userland policy
issue.
