From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] net, rps: bypass enqueue_to_backlog()
Date: Wed, 18 Dec 2013 06:26:10 -0800
Message-ID: <1387376770.19078.314.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387371816-32476-1-git-send-email-zwu.kernel@gmail.com>
	 <1387374979.19078.309.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1387375442.19078.310.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAEH94Lh-Dujb9YbpFK0kTu2O3pGSf16rXwCWFWBE50K_4geHnA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:33759 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754206Ab3LRO0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:26:06 -0500
Received: by mail-pb0-f49.google.com with SMTP id jt11so8470418pbb.22
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:26:06 -0800 (PST)
In-Reply-To: <CAEH94Lh-Dujb9YbpFK0kTu2O3pGSf16rXwCWFWBE50K_4geHnA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 22:11 +0800, Zhi Yong Wu wrote:

> it makes sense, but if cpu < 0, some packets seems to bypass the flow
> shedding stuff, That is, the flow limit will be not so accurate,
> right?

Not sure what you mean.

cpu = -1 on very rare occasions, like cpu hot unplug.

In netif_receive_skb(), we just process the packet normally.
