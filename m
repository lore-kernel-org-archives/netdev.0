From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: tproxy: properly refcount tcp listeners
Date: Thu, 18 Aug 2016 00:51:40 +0200
Message-ID: <20160817225140.GA5966@salvia>
References: <627722c51d9ce454dfaf1a79519ceb59@nuclearcat.com>
 <1471448525.29842.1.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471449871.29842.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <09c3ca74357572464b5ff280f1cd0ddc@nuclearcat.com>
 <1471453006.29842.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51222 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752761AbcHQWvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 18:51:44 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 29E0AE8E8D
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 00:51:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1B116FF153
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 00:51:43 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1822FFF153
	for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 00:51:41 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1471453006.29842.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 09:56:46AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> inet_lookup_listener() and inet6_lookup_listener() no longer
> take a reference on the found listener.
> 
> This minimal patch adds back the refcounting, but we might do
> this differently in net-next later.

Applied, thanks Eric!
