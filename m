From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH v2 net-next] ipv6: router reachability probing
Date: Thu, 12 Dec 2013 10:10:05 +0100
Message-ID: <20131212091004.GA10703@unicorn.suse.cz>
References: <d483b5eedcbfedc2002c458b15586679e7795399.1386766078.git.jbenc@redhat.com>
 <20131211231236.GA8953@lion.mk-sys.cz>
 <20131212012115.GE4675@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
To: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:52101 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab3LLJKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 04:10:08 -0500
Content-Disposition: inline
In-Reply-To: <20131212012115.GE4675@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 12, 2013 at 02:21:15AM +0100, Hannes Frederic Sowa wrote:
> 
> Yeah, I think your analysis is correct. Also you can see that (at least) I did
> not considered this worth for -stable but only for net-next. ;)

On the other hand, the fix could be worth backporting to 3.4 stable
(more general, pre-3.6 stable branches) as the problem is much more
severe there.

                                                     Michal Kubecek
