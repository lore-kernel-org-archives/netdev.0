From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 4/4] openvswitch: Serialize nested ct actions if
 provided
Date: Wed, 21 Oct 2015 19:34:26 -0700 (PDT)
Message-ID: <20151021.193426.1057819461972247712.davem@davemloft.net>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
	<1445307540-6786-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	jrajahalme@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756341AbbJVCSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:18:00 -0400
In-Reply-To: <1445307540-6786-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Mon, 19 Oct 2015 19:19:00 -0700

> If userspace provides a ct action with no nested mark or label, then the
> storage for these fields is zeroed. Later when actions are requested,
> such zeroed fields are serialized even though userspace didn't
> originally specify them. Fix the behaviour by ensuring that no action is
> serialized in this case, and reject actions where userspace attempts to
> set these fields with mask=0. This should make netlink marshalling
> consistent across deserialization/reserialization.
> 
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied.
