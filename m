From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Sun, 20 Jul 2008 18:07:28 -0700 (PDT)
Message-ID: <alpine.LFD.1.10.0807201804410.31863@woody.linux-foundation.org>
References: <20080720.104411.81744468.davem@davemloft.net> <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59500 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754238AbYGUBIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 21:08:07 -0400
In-Reply-To: <alpine.LFD.1.10.0807201751440.31863@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



This warning also seems to be new:

	net/ipv6/addrconf.c: In function =A1addrconf_add_linklocal=A2:
	net/ipv6/addrconf.c:2318: warning: unused variable =A1net=A2

and looking at the code it's apparently because I'm not an optimistic=20
enough dad.

But hey, if you had three pre-teenage girls, you might not be all that=20
optimistic either. So I think that's reasonable.

Problem seems to have been introduced by 53b7997f ("ipv6 netns: Make=20
several "global" sysctl variables namespace aware")

		Linus
