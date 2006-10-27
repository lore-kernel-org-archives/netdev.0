From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Fri, 27 Oct 2006 14:22:06 -0700 (PDT)
Message-ID: <20061027.142206.104034351.davem@davemloft.net>
References: <20061026.170221.99202188.davem@davemloft.net>
	<20061027104311.GB3967@c3po.0xdef.net>
	<20061027074102.2a6fef4b@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5272
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752469AbWJ0VWF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 17:22:05 -0400
To: shemminger@osdl.org
In-Reply-To: <20061027074102.2a6fef4b@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 27 Oct 2006 07:41:02 -0700

> Please no, it makes the socket option useless.
> If you want to tag some "bad apples" thats okay, but would need
> some more infrastructure.

The behavior of the TCP stack is a system wide decision.

If anything it should be "everything besides the default
and Reno are offlimits to unprivileged users" with an
administrative method to override that.
