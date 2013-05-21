From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Tue, 21 May 2013 08:38:13 -0700
Message-ID: <1369150693.3301.233.camel@edumazet-glaptop>
References: <519B38EC.90401@yandex-team.ru>
	  <20130521120906.GD3578@linux.vnet.ibm.com>
	 <1369143885.3301.221.camel@edumazet-glaptop>
	 <519B8908.9080007@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Dipankar Sarma <dipankar@in.ibm.com>,
	zhmurov@yandex-team.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:36581 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754478Ab3EUPiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 11:38:16 -0400
In-Reply-To: <519B8908.9080007@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 18:47 +0400, Roman Gushchin wrote:

> This code has the same mistake: it is rcu_dereference_raw(head->first), 
> so there is nothing that prevents gcc to store the (head->first) value 
> in a register.

If other rcu accessors have the same problem, a more complete patch is
needed.

Thanks
