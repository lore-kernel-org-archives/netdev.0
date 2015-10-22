From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 3/4] openvswitch: Mark connections new when not
 confirmed.
Date: Wed, 21 Oct 2015 19:34:20 -0700 (PDT)
Message-ID: <20151021.193420.144509817688460416.davem@davemloft.net>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
	<1445307540-6786-3-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	jrajahalme@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459AbbJVCRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:17:54 -0400
In-Reply-To: <1445307540-6786-3-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Mon, 19 Oct 2015 19:18:59 -0700

> New, related connections are marked as such as part of ovs_ct_lookup(),
> but they are not marked as "new" if the commit flag is used. Make this
> consistent by setting the "new" flag whenever !nf_ct_is_confirmed(ct).
> 
> Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Applied.
