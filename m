From: David Miller <davem@davemloft.net>
Subject: Re: pull request [net]: batman-adv 20140721
Date: Mon, 21 Jul 2014 20:19:37 -0700 (PDT)
Message-ID: <20140721.201937.2036288525192398014.davem@davemloft.net>
References: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaGVD1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:27:04 -0400
In-Reply-To: <1405929211-30187-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon, 21 Jul 2014 09:53:29 +0200

> here you have two fixes that we have been testing for quite some time
> (this is why they arrived a bit late in the rc cycle).
> 
> Patch 1) ensures that BLA packets get dropped and not forwarded to the
> mesh even if they reach batman-adv within QinQ frames. Forwarding them
> into the mesh means messing up with the TT database of other nodes which
> can generate all kind of unexpected behaviours during route computation.
> 
> Patch 2) avoids a couple of race conditions triggered upon fast VLAN
> deletion-addition. Such race conditions are pretty dangerous because
> they not only create inconsistencies in the TT database of the nodes
> in the network, but such scenario is also unrecoverable (unless
> nodes are rebooted).
 ...
>   git://git.open-mesh.org/linux-merge.git tags/batman-adv-fix-for-davem

Pulled, thanks Antonio.
