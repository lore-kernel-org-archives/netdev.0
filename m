From: David Miller <davem@davemloft.net>
Subject: Re: pull request net: batman-adv 2014-08-04
Date: Tue, 05 Aug 2014 16:22:49 -0700 (PDT)
Message-ID: <20140805.162249.1442705693919283325.davem@davemloft.net>
References: <1407167221-10575-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbaHEXWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:22:51 -0400
In-Reply-To: <1407167221-10575-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon,  4 Aug 2014 17:47:00 +0200

> this is a pull request intended for net.
> 
> It just contains a patch by Sven Eckelmann that fixes the
> reception of out-of-order fragments. As explained in the
> commit message, the issue was due to a wrong assumption
> about hlist_for_each_entry() in batadv_frag_insert_packet().
> 
> Please pull or let me know of any problem.
> *If possible, this patch should also be enqueued for stable*

As you can see this didn't make it in time for the 3.16 release,
I've pulled and queued this patch up for -stable.
