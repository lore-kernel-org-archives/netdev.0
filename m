From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] inet: frag: cleanup and update
Date: Sun, 27 Jul 2014 22:37:18 -0700 (PDT)
Message-ID: <20140727.223718.1055588669834128686.davem@davemloft.net>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	alex.aring@gmail.com, eric.dumazet@gmail.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbaG1FhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 01:37:20 -0400
In-Reply-To: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 24 Jul 2014 16:50:28 +0200

> The end goal of this patchset is to remove the LRU list and to move the
> frag eviction to a work queue. It also does a couple of necessary cleanups
> and fixes. Brief patch descriptions:

Ok I decided to apply this series.

Honestly I thought the frag counter would be useful for diagnosing problems
("are there a lot of frag queues bunched up on my machine?").  But whatever.

You could make it accurate again by just scanning the hash table really
quickly and counting how many entries you see, if you wanted to.
