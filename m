From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: sctp: inherit auth_capable on INIT
 collisions
Date: Tue, 22 Jul 2014 19:57:42 -0700 (PDT)
Message-ID: <20140722.195742.54662767046721264.davem@davemloft.net>
References: <1406035365-1154-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgunthorpe@obsidianresearch.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, vyasevich@gmail.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755029AbaGWC5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:57:44 -0400
In-Reply-To: <1406035365-1154-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 22 Jul 2014 15:22:45 +0200

> Jason reported an oops caused by SCTP on his ARM machine with
> SCTP authentication enabled:
 ...
> While we already had various kind of bugs in that area
> ec0223ec48a9 ("net: sctp: fix sctp_sf_do_5_1D_ce to verify if
> we/peer is AUTH capable") and b14878ccb7fa ("net: sctp: cache
> auth_enable per endpoint"), this one is a bit of a different
> kind.
 ...
> The correct fix is to update to the new peer.auth_capable
> value as well in the collision case via sctp_assoc_update(),
> so that in case the collision migrated from 0 -> 1,
> sctp_auth_asoc_init_active_key() can properly recalculate
> the secret. This therefore fixes the observed server panic.
> 
> Fixes: 730fc3d05cd4 ("[SCTP]: Implete SCTP-AUTH parameter processing")
> Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Tested-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>

Applied.
