From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Mon, 04 Jun 2012 21:56:52 +0200
Message-ID: <1338839812.2760.1939.camel@edumazet-glaptop>
References: <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604172030.GA32205@redhat.com>
	 <1338831890.2760.1842.camel@edumazet-glaptop>
	 <20120604181636.GG32205@redhat.com>
	 <1338837842.2760.1883.camel@edumazet-glaptop>
	 <20120604194806.GB1648@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:52562 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568Ab2FDT44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:56:56 -0400
Received: by bkcji2 with SMTP id ji2so3956232bkc.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 12:56:55 -0700 (PDT)
In-Reply-To: <20120604194806.GB1648@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 22:48 +0300, Michael S. Tsirkin wrote:

> If I do this what will truesize be? 128, no?

My example was not correct, since you must have enough room for the
SKB_DATA_ALIGN(sizeof(struct skb_shared_info))  ( 320 bytes )

So it would be 128 + 320 = 448
