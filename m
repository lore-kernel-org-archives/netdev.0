From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net 1/4] openvswitch: Reject ct_state masks for
 unknown bits
Date: Wed, 21 Oct 2015 19:34:07 -0700 (PDT)
Message-ID: <20151021.193407.1363766138623635486.davem@davemloft.net>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com, tgraf@suug.ch,
	jrajahalme@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752475AbbJVCRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 22:17:42 -0400
In-Reply-To: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Mon, 19 Oct 2015 19:18:57 -0700

> Currently, 0-bits are generated in ct_state where the bit position is
> undefined, and matches are accepted on these bit-positions. If userspace
> requests to match the 0-value for this bit then it may expect only a
> subset of traffic to match this value, whereas currently all packets
> will have this bit set to 0. Fix this by rejecting such masks.
> 
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> Acked-by: Pravin B Shelar <pshelar@nicira.com>
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied.
