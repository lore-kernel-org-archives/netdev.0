From: David Miller <davem@davemloft.net>
Subject: Re: pull request: batman-adv 2014-08-05
Date: Tue, 05 Aug 2014 16:40:09 -0700 (PDT)
Message-ID: <20140805.164009.1703458407190401181.davem@davemloft.net>
References: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60482 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbaHEXkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:40:10 -0400
In-Reply-To: <1407224188-28626-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue,  5 Aug 2014 09:36:24 +0200

> this is a pull request intended for net-next/linux-3.17 (yeah..it's really
> late).
> 
> Patches 1, 2 and 4 are really minor changes:
> - kmalloc_array is substituted to kmalloc when possible (as suggested by
>   checkpatch);
> - net_ratelimited() is now used properly and the "suppressed" message is not
>   printed anymore if not needed;
> - the internal version number has been increased to reflect our current version.
> 
> Patch 3 instead is introducing a change in the metric computation function
> by changing the penalty applied at each mesh hop from 15/255 (~6%) to
> 30/255 (~11%). This change is introduced by Simon Wunderlich after having
> observed a performance improvement in several networks when using the new value.

Pulled, thanks Antonio.
