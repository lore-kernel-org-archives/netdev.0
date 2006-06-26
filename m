From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Mon, 26 Jun 2006 10:46:54 -0700 (PDT)
Message-ID: <20060626.104654.98552111.davem@davemloft.net>
References: <20060626145446.948105000@postel.suug.ch>
	<20060626145515.769648000@postel.suug.ch>
	<44A0138F.8050208@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5534
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932079AbWFZRqz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 13:46:55 -0400
To: kaber@trash.net
In-Reply-To: <44A0138F.8050208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 26 Jun 2006 19:04:15 +0200

> I know this was discussed before, but I can't remember the
> exact outcome. Why don't we just unconditionally update iif
> in netif_receive_skb()?

Software devices might have interesting semantics that would
make not setting iif desirable.

Once you set iif, you can't just undo it because the information
is lost.

I also would really prefer to set it unconditionally in
netif_receive_skb(), but Jamal's concerns in this area are real.
We really need to evaluate this on a case-by-case basis.
