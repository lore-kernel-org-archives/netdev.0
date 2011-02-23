From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 v4] net_sched: SFB flow scheduler
Date: Wed, 23 Feb 2011 13:11:58 -0800
Message-ID: <20110223131158.632dc45c@nehalam>
References: <20110221160306.GA9650@tuxdriver.com>
	<1298308283.2849.5.camel@edumazet-laptop>
	<1298390536.2861.9.camel@edumazet-laptop>
	<1298474091.3301.364.camel@edumazet-laptop>
	<1298494577.2898.9.camel@edumazet-laptop>
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
Received: from mail.vyatta.com ([76.74.103.46]:56692 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024Ab1BWVMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 16:12:00 -0500
In-Reply-To: <1298494577.2898.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Feb 2011 21:56:17 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +struct Qdisc_ops sfb_qdisc_ops __read_mostly = {

Should be static?


-- 
