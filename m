From: Ingo Molnar <mingo@elte.hu>
Subject: Re: auro deadlock
Date: Mon, 10 Jul 2006 08:59:52 +0200
Message-ID: <20060710065952.GA25867@elte.hu>
References: <20060707171916.GA16343@redhat.com> <1152295989.3111.116.camel@laptopd505.fenrus.org> <20060707.120936.98532669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: arjan@infradead.org, davej@redhat.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:28034 "EHLO mx2.mail.elte.hu")
	by vger.kernel.org with ESMTP id S1161362AbWGJHE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 03:04:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060707.120936.98532669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> The lockdep fixes are starting to cause us to go in and start adding 
> hard IRQ protection to many socket layer objects and I want this 
> thinking to end quickly :)

In earlier lockdep versions we had many such hacks, but in the current 
upstream kernel we've only got one such case so far: one netlink 
function, where the alternative was to rewrite softmac. I fixed all the 
earlier hacks to be proper annotations - and the plan is to keep things 
clean in the future too :-)

	Ingo
