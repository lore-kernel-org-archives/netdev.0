From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 3/3] tcp: better TCP_SKB_CB layout to reduce
 cache line misses
Date: Thu, 25 Sep 2014 11:36:35 -0700
Message-ID: <1411670195.16953.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1411468452-3729-1-git-send-email-edumazet@google.com>
	 <1411468452-3729-4-git-send-email-edumazet@google.com>
	 <20140925154844.GM5044@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52520 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaIYSgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 14:36:36 -0400
Received: by mail-pd0-f180.google.com with SMTP id r10so11296920pdi.39
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 11:36:36 -0700 (PDT)
In-Reply-To: <20140925154844.GM5044@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-25 at 17:48 +0200, Christoph Paasch wrote:

> I think that in tcp_v4_hnd_req() and tcp_v4_save_options() we also need to
> avoid calling IPCB() and do TCP_SKB_CB(skb)->header.h4.opt instead.

Hmm, it seems I lost this bit when splitting my original big patch into
3 smaller components.

Thanks !
