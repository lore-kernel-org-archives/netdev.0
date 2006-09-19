From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set congestion default through Kconfig
Date: Tue, 19 Sep 2006 12:30:54 -0700 (PDT)
Message-ID: <20060919.123054.83620346.davem@davemloft.net>
References: <20060918.115309.88343320.davem@davemloft.net>
	<20060918195224.GA26585@outpost.ds9a.nl>
	<20060918214104.3824a2e2@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp-2
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19848
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751033AbWISTat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:30:49 -0400
To: shemminger@osdl.org
In-Reply-To: <20060918214104.3824a2e2@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Actually, I take that back:

net/ipv4/sysctl_net_ipv4.c: In function $,1rx(Btcp_congestion_default$,1ry(B:
net/ipv4/sysctl_net_ipv4.c:134: error: syntax error before $,1rx(B}$,1ry(B token
net/ipv4/sysctl_net_ipv4.c: At top level:
net/ipv4/sysctl_net_ipv4.c:136: warning: initialization from incompatible pointer type

I'll fix this up, but I'm seeing a very disturbing pattern lately
of very clueful people posting patches without typing "make".

Is this too much to ask these days?  This costs me an enormous
amount of time, to review someone's patch and verify it's logical
correctness, only to check it in and find out that it doesn't
even build.  That, frankly, is unacceptable.
