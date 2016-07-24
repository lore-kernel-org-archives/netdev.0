From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: kernel panic, __neigh_notify, 4.7.0-rc7, Workqueue:
 events_power_efficient neigh_periodic_work
Date: Mon, 25 Jul 2016 00:01:36 +0300
Message-ID: <2fef7973e5b46a3707e74cc3e47cc40f@nuclearcat.com>
References: <fca2656caca69658277c685de29576ae@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:60932 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006AbcGXVBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2016 17:01:40 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id 60A1D67C002E
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 21:01:38 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id h17JfaoH4WUV for <netdev@vger.kernel.org>;
	Sun, 24 Jul 2016 21:01:36 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id 91C3D67C002C
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 21:01:36 +0000 (UTC)
In-Reply-To: <fca2656caca69658277c685de29576ae@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-07-24 21:40, nuclearcat@nuclearcat.com wrote:
> Different hardware, but same workload. Seems different bug, happened
> at least twice on this unit (both kernel panic messages here)
As additional sidenote, that might be useful (found in commits, that 
proxy arp might induce this bug, such as in commit "net/neighbour: fix 
crash at dumping device-agnostic proxy entries"): it is pppoe server 
with proxy_arp running on it
