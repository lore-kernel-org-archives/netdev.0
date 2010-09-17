From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: keep vlan slaves on master netns move
Date: Fri, 17 Sep 2010 10:56:08 -0700 (PDT)
Message-ID: <20100917.105608.139110330.davem@davemloft.net>
References: <20100913114315.GA859019@jupiter.n2.diac24.net>
	<m1bp7z4v0m.fsf@fess.ebiederm.org>
	<20100917132219.GA2363813@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
	daniel.lezcano@free.fr
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47413
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755716Ab0IQRzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 13:55:49 -0400
In-Reply-To: <20100917132219.GA2363813@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Fri, 17 Sep 2010 15:22:19 +0200

> previously, if a vlan master device was moved from one network namespace
> to another, all 802.1q and macvlan slaves were deleted.
> 
> we can use dev->reg_state to figure out whether dev_change_net_namespace
> is happening, since that won't set dev->reg_state NETREG_UNREGISTERING.
> so, this changes 8021q and macvlan to ignore NETDEV_UNREGISTER when
> reg_state is not NETREG_UNREGISTERING.
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
> Acked-by: Patrick McHardy <kaber@trash.net>
> ---
> Hi David,
> 
> Q)ueue, F)eedback, A)pply?

I'll apply this when I get a chance, thanks.
