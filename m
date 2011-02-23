From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 v3] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 07:43:05 -0800
Message-ID: <20110223074305.755c5713@nehalam>
References: <20110221160306.GA9650@tuxdriver.com>
	<1298308283.2849.5.camel@edumazet-laptop>
	<1298390536.2861.9.camel@edumazet-laptop>
	<1298474091.3301.364.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34593 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab1BWPnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 10:43:08 -0500
In-Reply-To: <1298474091.3301.364.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Feb 2011 16:14:51 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> 1) SFB default child qdisc is pfifo_fast. It can be changed by another
> qdisc but a child qdisc MUST not drop a packet previously queued. This
> is because SFB needs to handle a dequeued packet in order to maintain
> its virtual queue states. pfifo_head_drop or CHOKe should not be used.

Why not add a flag field to Qdisc_ops and to mark qdisc's that
are (or not) work conserving?

-- 
