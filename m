From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 8 Jun 2010 12:57:28 +0800
Message-ID: <AANLkTilGemF6QxaqEW8pi6nlHvn9oFQ7xT8c3Le35nha@mail.gmail.com>
References: <1275921171.2545.102.camel@edumazet-laptop> <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	<1275924638.2545.121.camel@edumazet-laptop> <1275926151.2545.126.camel@edumazet-laptop>
	<1275929761.2545.159.camel@edumazet-laptop> <1275931108.2545.168.camel@edumazet-laptop>
	<AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
	<1275971457.2775.40.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f176.google.com ([209.85.222.176]:59967 "EHLO
	mail-pz0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab0FHE5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 00:57:49 -0400
Received: by pzk6 with SMTP id 6so1930284pzk.1
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 21:57:48 -0700 (PDT)
In-Reply-To: <1275971457.2775.40.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 8, 2010 at 12:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Thank you for asking this question.
>
> Because I want to kill RTNL when possible, I dont even want to try
> adding RTNL to xt_RATEEST and solve all lock dependencies it might
> raise.
>
> RTNL = Big and Horrible Network LOCK
>

It is much like the BKL, and should be killed too. Thanks. :)


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
