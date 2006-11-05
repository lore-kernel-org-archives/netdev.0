From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH] Purging local routes on NETDEV_DOWN event
Date: Sun, 05 Nov 2006 13:16:58 -0800 (PST)
Message-ID: <20061105.131658.125893985.davem@davemloft.net>
References: <589170c50611050600r3d4bfaafvb2acd513ae695a96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38557
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965689AbWKEVRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 16:17:00 -0500
To: bobatonhu@gmail.com
In-Reply-To: <589170c50611050600r3d4bfaafvb2acd513ae695a96@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Boris Sukholitko" <bobatonhu@gmail.com>
Date: Sun, 5 Nov 2006 16:00:20 +0200

> We've noticed that when taking network interface down the local route
> for its address is preserved.

This behavior is intentional.  IP addresses are associated with the
system, not a particular network interface.  So if you want the IP and
it's local subnet route to go away, you must explicitly delete that IP
address from the interface, just downing the interface is not
sufficient.
