From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH v3] xmit_compl_seq: information to reclaim vmsplice buffers
Date: Mon, 27 Sep 2010 14:49:27 -0700
Message-ID: <AANLkTikmpfsBMRu2DPWKoR9pmQ9R-1MmxaZgoyB6y7Zi@mail.gmail.com>
References: <alpine.DEB.1.00.1009231426450.11579@pokey.mtv.corp.google.com>
	<20100927172315.GA8387@redhat.com>
	<AANLkTimdrFuYONq6FvBW41AnhpA6Q+acSUmy4CiJatYL@mail.gmail.com>
	<1285614757.2512.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, sridharr@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:47009 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755887Ab0I0Vtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 17:49:31 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o8RLnTVd003159
	for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 14:49:29 -0700
Received: from pvb32 (pvb32.prod.google.com [10.241.209.96])
	by hpaq2.eem.corp.google.com with ESMTP id o8RLmuk6016490
	for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 14:49:28 -0700
Received: by pvb32 with SMTP id 32so2323359pvb.15
        for <netdev@vger.kernel.org>; Mon, 27 Sep 2010 14:49:27 -0700 (PDT)
In-Reply-To: <1285614757.2512.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Alternative would be to copy data on retransmits, for tcp sockets using
> SOCK_XMIT_COMPL_SEQ. (ie not using skb_clone but skb_copy())
>

That's coming awfully close to COW! ;-)

>
>
>
>
