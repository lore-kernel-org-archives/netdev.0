From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 13:37:52 -0700 (PDT)
Message-ID: <20060627.133752.21929335.davem@davemloft.net>
References: <1151439548.20252.2.camel@stevo-desktop>
	<20060627.132132.21596632.davem@davemloft.net>
	<1151440399.20252.9.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15825
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161296AbWF0Uhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:37:53 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151440399.20252.9.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Tue, 27 Jun 2006 15:33:19 -0500

> From my experimentation with netlink, RTM_NEWROUTE and RTM_DELROUTE
> messages do not get sent up for redirect events.  I have, in fact, added
> this with the new patch I'll send out soon.  So either way I need to
> change the IPv[46] code to generate a notification for redirects.  With
> the single NETEVENT_REDIRECT call, the RDMA driver can, in one sweep,
> update all the connections.  It seems more efficient.  At the place
> where I've hooked redirect, both the old route and the new route are
> already created.

Ok, let's see what it looks like.
