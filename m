From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: netdev_alloc_skb() use build_skb()
Date: Tue, 05 Jun 2012 04:46:35 +0200
Message-ID: <1338864395.2760.1967.camel@edumazet-glaptop>
References: <20120604123738.GA28992@redhat.com>
	 <1338815213.2760.1806.camel@edumazet-glaptop>
	 <20120604134138.GA29814@redhat.com>
	 <1338818501.2760.1821.camel@edumazet-glaptop>
	 <20120604141731.GA30226@redhat.com>
	 <1338822064.2760.1834.camel@edumazet-glaptop>
	 <20120604181623.GF32205@redhat.com>
	 <1338838185.2760.1899.camel@edumazet-glaptop>
	 <20120604194330.GA1648@redhat.com>
	 <1338839579.2760.1932.camel@edumazet-glaptop>
	 <20120604215434.GB3193@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47512 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757696Ab2FECql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 22:46:41 -0400
Received: by weyu7 with SMTP id u7so3268386wey.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 19:46:39 -0700 (PDT)
In-Reply-To: <20120604215434.GB3193@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 00:54 +0300, Michael S. Tsirkin wrote:

> Yes but what bugs me if the box is not under memory pressure
> this overestimation limits buffers for no real gain.
> How about we teach tcp to use data_len for buffer
> limits normally and switch to truesize when low on memory?
> 

You should first have evidence of the effect of this limitation.

I see more evidence of poor choices at driver level than core level.
