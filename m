From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 01 Feb 2013 07:22:38 -0800
Message-ID: <1359732158.30177.46.camel@edumazet-glaptop>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
		 <20130201.010946.584437309593473452.davem@davemloft.net>
	 <1359700003.30177.32.camel@edumazet-glaptop> <510B6B4B.8080205@gmail.com>
	 <1359703264.30177.37.camel@edumazet-glaptop>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B712D@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xue Ying <ying.xue0@gmail.com>, David Miller <davem@davemloft.net>,
	ying.xue@windriver.com, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:59143 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754200Ab3BAPWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 10:22:49 -0500
Received: by mail-pb0-f47.google.com with SMTP id rp8so2186253pbb.20
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 07:22:48 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B712D@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-01 at 09:26 +0000, David Laight wrote:

> If timer_pending() is an inline function then the additional check
> might be beneficial in very hot paths.

The 'If' word you use show you didn't even read the code, and you
are talking to linux netdev mailing list. We already know these things.

So what are these very hot paths you identified ?

If this was a real concern, the right thing to do is to have a generic
helper so that its real clear and self documented.

BTW sk_stop_timer() could be inlined.
