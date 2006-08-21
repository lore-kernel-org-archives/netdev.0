From: David Miller <davem@davemloft.net>
Subject: Re: 800+ byte inlines in include/net/pkt_act.h
Date: Mon, 21 Aug 2006 16:38:01 -0700 (PDT)
Message-ID: <20060821.163801.15260979.davem@davemloft.net>
References: <200608201933.10293.vda.linux@googlemail.com>
	<1156163160.5126.47.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vda.linux@googlemail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1744
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751351AbWHUXhq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 19:37:46 -0400
To: hadi@cyberus.ca
In-Reply-To: <1156163160.5126.47.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Mon, 21 Aug 2006 08:26:00 -0400

> As per last discussion, either Patrick McHardy or myself are going
> to work on it - at some point. Please be patient. The other
> alternative is: you fix it and send patches.

I'm working on it right now.  This code is really gross and needs
to be fixed immediately.

What I'll do is define a "struct tcf_common" and have the generic
interfaces take that as well as a "struct tcf_hashinfo *" parameter to
deal with the individual hash tables.

We define all of this templated stuff then don't even use it in
act_police.c, we just duplicate everything!

Absolutely unbelievable.
